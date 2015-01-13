class Project < ActiveRecord::Base
  include AASM

  #FIXME_AB: Following constants should be application configuration/constants
  BEST_PROJECTS_LIMIT           = 4
  INITIAL_PROJECT_DISPLAY_LIMIT = 28

  # -------------- SECTION FOR ASSOCIATIONS ---------------------
  # -------------------------------------------------------------
  has_many :images, -> { where document: false }, as: :imageable
  has_many :legal_documents, -> { where document: true }, as: :imageable, class_name: 'Image'
  belongs_to :user
  #FIXME_AB: Dependent option ?
  has_many :comments, dependent: :destroy

  has_attached_file :project_picture, styles: {
                              thumbnail: '270x220^',
                              medium: { geometry: '370x300^', quality: 100 },
                              large: { geometry: '770x300^', quality: 100 }
                            },
                            convert_options: {
                              thumbnail: " -gravity center -crop '270x220+0+0'",
                              medium: " -gravity center -crop '370x300+0+0'",
                              large: " -gravity Center -extent 770x300"
                            },
                            default_url: '/images/img/gallery/default_project_:style.jpg'


  accepts_nested_attributes_for :images, :legal_documents

  after_validation :filter_images_error_messages

  # -------------- SECTION FOR CALLBACKS ------------------------
  # -------------------------------------------------------------
  #FIXME_AB: doing same thing in before_create and before_update. Can before_save be used?\
  before_save :set_time_to_midnight, unless: Proc.new { |project| project.end_date.nil? }
  before_update :set_time_to_midnight, unless: Proc.new { |project| project.end_date.nil? }

  # -------------- SECTION FOR STATE MACHINE --------------------
  # -------------------------------------------------------------
  aasm column: 'state'.freeze do
    state :created, initial: true
    state :published
    state :unpublished
    state :successful
    state :failed
    state :fraud
    state :payment_pending
    state :reached_end_date

    event :publish do
      transitions from: [:created, :unpublished], to: :published
    end

    event :unpublish do
      transitions from: [:created, :published, :fraud], to: :unpublished
    end

    event :successful do
      transitions from: :payment_pending, to: :unpublished
    end

    event :payment_pending do
      transitions from: :published, to: :payment_pending
    end

    event :failed do
      transitions from: [:published, :payment_pending], to: :failed
    end

    event :fraud do
      transitions from: [:published, :unpublished, :created, :payment_pending], to: :failed
    end

  end

  # -------------- SECTION FOR VALIDATIONS ----------------------
  # -------------------------------------------------------------
  validates :type, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :amount_required, presence: true
  validates :min_amount_per_contribution, presence: true

  #FIXME_AB: You should not be worried about beginning_of_day here when using you validation here. It should be taken care by the validator. 
  validates :end_date, presence: true
  
  validates :end_date, allow_nil: true, date: { greater_than_or_equal_to: (5.days.from_now.beginning_of_day) }, if: :end_date_changed?
  # validates :title, uniqueness: true, allow_blank: true
  validates :title, length: { maximum: 250 }
  validates :amount_required, allow_nil: true, numericality: { greater_than: 0, less_than_or_equal_to: 10000000 }
  validates :min_amount_per_contribution, allow_nil: true, numericality: { greater_than: 0, less_than_or_equal_to: :amount_required }
  validates :description, length: { maximum: 10000 }
  validate :amount_multiple_of_100
  validate :min_amount_multiple_of_10
  validates_attachment_content_type :project_picture, content_type: %w(image/jpg image/jpeg image/png image/gif)

  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------
  scope :charity, -> { where(type: 'CharityProject') }
  scope :investment, -> { where(type: 'InvestmentProject') }
  scope :published, -> { where(state: :published) }
  scope :successful, -> { where(state: :successful) }
  #FIXME_AB: I am not generally in favor of defining scopes for order. Scopes should be used to scope a collection.
  scope :order_by_creation, -> { order(created_at: :desc) }
  scope :order_by_updation, -> { order(updated_at: :desc) }
  scope :projects_to_be_approved, -> { where(state: [:created, :unpublished]).order_by_creation }
  #FIXME_AB: Also I am not in favor of making scops for paginations :) It should be a controller thing
  scope :published_projects, -> (page = 1) { published.limit_records(page).order_by_updation }
  scope :published_charity_projects, -> (page = 1) { charity.published.limit_records(page).order_by_updation }
  scope :published_investment_projects, -> (page = 1) { investment.published.limit_records(page).order_by_updation }
  scope :limit_records, -> (page = 1) { limit(INITIAL_PROJECT_DISPLAY_LIMIT).offset((page - 1) * INITIAL_PROJECT_DISPLAY_LIMIT) }
  #TODO: amount_required - 100 to be replaced by - amount_collected
  scope :popular, -> { published.order('((amount_required - 100) / 100) DESC').limit(BEST_PROJECTS_LIMIT) }
  scope :completed, -> { successful.order(amount_required: :desc).limit(BEST_PROJECTS_LIMIT) }
  scope :recent, -> { published.order(updated_at: :desc).limit(BEST_PROJECTS_LIMIT) }

  # To determine which all projects we can make
  def self.types
    %w(CharityProject InvestmentProject)
  end

  def amount_multiple_of_100
    errors[:amount_required] << 'should be a multiple of 100' if (amount_required.to_i % 100).nonzero?
  end

  def min_amount_multiple_of_10
    errors[:min_amount_per_contribution] << 'should be a multiple of 10' if (min_amount_per_contribution.to_i % 10).nonzero?
  end

  # It reduces and fixes the error messages for the attachments in an association.
  def filter_images_error_messages
    new_error_messages = {}

    errors.each do |attribute, msg|
      if [:'images.image', :'legal_documents.image', :project_picture].include? attribute
        errors.delete(attribute)
      elsif attribute.match(/([A-z_0-9]+)(\.([A-z_0-9]+))+/)
        key_index = $3.index('_') + 1
        key_string = $3[key_index..-1].humanize + ' '
        new_error_messages[$1] ||= key_string.downcase + errors[attribute].first
        errors.delete(attribute)
      end
    end

    new_error_messages.each do |key, value|
      errors.add(key, value)
    end
    
  end

  def check_end_date
    self.end_date >= 5.days.from_now.beginning_of_day
  end

  def self.cached_recent(exclude_ids = nil)
    Rails.cache.fetch([name, 'recent'], expires_in: 30.minutes) do
      exclude_ids ? Project.recent.where.not(id: exclude_ids).to_a : Project.recent.to_a
    end
  end

  def self.cached_popular(exclude_ids = nil)
    Rails.cache.fetch([name, 'popular'], expires_in: 30.minutes) do
      exclude_ids ? Project.popular.where.not(id: exclude_ids).to_a : Project.popular.to_a
    end
  end

  def self.cached_completed(exclude_ids = nil)
    Rails.cache.fetch([name, 'completed'], expires_in: 30.minutes) do
      exclude_ids ? Project.completed.where.not(id: exclude_ids).to_a : Project.completed.to_a
    end
  end

  # -------------- STATE MACHINE METHODS START------------

  # -------------- STATE MACHINE METHODS END --------------

  protected
    def set_time_to_midnight
      self.end_date = self.end_date.at_end_of_day
    end

end

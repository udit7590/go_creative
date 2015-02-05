class Project < ActiveRecord::Base
  include AASM

  paginates_per Constants::PROJECT_LIST_PAGE_LIMIT
  max_paginates_per 100

  # -------------- SECTION FOR ASSOCIATIONS ---------------------
  # -------------------------------------------------------------
  has_many :images, -> { where document: false }, as: :imageable
  has_many :legal_documents, -> { where document: true }, as: :imageable, class_name: 'Image'
  belongs_to :user
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
                            }

  has_many :contributions
  has_many :contributors, through: :contributions, dependent: :restrict_with_error

  accepts_nested_attributes_for :images, :legal_documents

  after_validation :filter_images_error_messages

  # -------------- SECTION FOR CALLBACKS ------------------------
  # -------------------------------------------------------------
  before_save :set_time_to_midnight, unless: Proc.new { |project| project.end_date.nil? }
  before_save :sanitize_description
  after_save :expire_cache
  
  # handle_asynchronously :expire_end_date, run_at: => Proc.new { end_date }

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
    state :rejected
    state :cancelled

    event :publish do
      transitions from: [:created, :unpublished], to: :published
    end

    event :unpublish do
      transitions from: [:created, :published, :fraud], to: :unpublished
    end

    event :reject do
      transitions from: [:created, :unpublished], to: :rejected
    end

    event :successful do
      transitions from: [:payment_pending, :published], to: :successful
    end

    event :payment_pending do
      transitions from: :published, to: :payment_pending
    end

    event :fail do
      transitions from: [:published, :payment_pending], to: :failed
    end

    event :fraud do
      transitions from: [:published, :unpublished, :created, :payment_pending], to: :fraud
    end

    event :cancel, before: :refund_collected_amount do
      transitions from: [:published, :unpublished, :created, :payment_pending], to: :cancelled
    end

  end

  # -------------- SECTION FOR VALIDATIONS ----------------------
  # -------------------------------------------------------------
  validates :type, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :amount_required, presence: true
  validates :min_amount_per_contribution, presence: true

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

  validates :images, length: { maximum: 10, message: 'can have maximum 10 images' }
  validates :legal_documents, length: { maximum: 10, message: 'can have maximum 10 legal documents' }

  # -------------- SECTION FOR SCOPES ---------------
  # -------------------------------------------------------------
  # Scopes for project type
  scope :charity, -> { where(type: 'CharityProject') }
  scope :investment, -> { where(type: 'InvestmentProject') }

  # Scopes for project state
  scope :published, -> { where(state: :published) }
  scope :successful, -> { where(state: :successful) }

  scope :order_by_creation, -> { order(created_at: :desc) }
  scope :order_by_updation, -> { order(updated_at: :desc) }
  scope :projects_to_be_approved, -> { where(state: [:created, :unpublished]).order_by_creation }
  scope :limit_records, -> (page = 1) { limit(Constants::PROJECT_LIST_PAGE_LIMIT).offset((page - 1) * Constants::PROJECT_LIST_PAGE_LIMIT) }

  # SORTING SCOPES
  scope :popular, -> { published.order('(collected_amount / amount_required) DESC') }
  scope :completed, -> { successful.order(amount_required: :desc) }
  scope :recent_published, -> { published.order_by_updation }
  scope :recent_published_charity, -> { charity.recent_published }
  scope :recent_published_investment, -> { investment.recent_published }
  scope :ending_soon, -> { published.order(:end_date) }

  # -------------- SECTION FOR METHODS ---------------
  # -------------------------------------------------------------

  # To determine which all projects we can make
  def self.types
    %w(CharityProject InvestmentProject)
  end

  def check_end_date
    self.end_date >= 5.days.from_now.beginning_of_day
  end

  def percentage_completed
    ((collected_amount / amount_required) * 100) if amount_required > 0
  end

  def contributions_count
    contributors_count.to_i > 0 ? contributors_count : contributions.accepted.count
  end

  def amount_collected
    collected_amount.to_i > 0 ? collected_amount : contributions.accepted.sum(:amount)
  end

  def amount_left
    amount_required - amount_collected
  end

  def min_amount
    ((min_amount_per_contribution < amount_left) ? min_amount_per_contribution : amount_left).to_i
  end

  def requires_donation?
    !(successful? || failed? || amount_left <= 0)
  end
  
  def can_be_accessed_by?(user)
    published? || successful? || payment_pending? || failed? || user_id == user.try(:id)
  end

  def owner?(user)
    return false unless user
    user_id == user.id
  end

  def publishable?
    created? || unpublished?
  end

  def cancelable?
    published? || payment_pending?
  end

  # CRITICAL: Completes a project
  def complete!
    if contributions.accepted.sum(:amount) >= amount_required
      successful!
    end
  end

  # SORTING CRITERIA
  def self.sort_by(criteria, order_by = :desc)
    case criteria
    when :popularity
      Project.popular
    when :recent
      Project.recent_published
    when :ending_soon
      Project.ending_soon
    else
      Project.published.order(:created_at)
    end
  end

  # FILTERING CRITERIA
  def self.filter_by(criteria, order_by = :desc)
    case criteria
    when :charity
      Project.charity
    when :investment
      Project.investment
    when :completed
      Project.successful
    end
  end

  def schedule_end_date_expiration
    if end_date >= DateTime.current
      delay.expire_end_date
    end
  end

  def expire_end_date
    if end_date >= DateTime.current
      # FUTURE: NEED TO CHECK IF MULTIPLE JOBS QUEUED
      if (amount_required <= amount_collected) && published?
        successful!
      else
        fail!
      end
    end
  end

  # Used by rake task
  def self.expire_old
    query_params = { state: :published, date_today: DateTime.current }
    (where("state = :state AND end_date <= :date_today", query_params).each do |project|
          project.expire_end_date
        end).length
  end

  # -------------- SECTION FOR CACHING METHODS ----------------------
  # -----------------------------------------------------------------

  # To be Expired on project create/update
  def self.cached_recent(number_of_records = Constants::PROJECT_HOME_PAGE_LIMIT, exclude_ids = nil)
    Rails.cache.fetch([name, 'recent'], expires_in: 15.minutes) do
      exclude_ids ? Project.recent_published.where.not(id: exclude_ids).limit(number_of_records).to_a : Project.recent_published.limit(number_of_records).to_a
    end
  end

  # To be Expired on project contribution
  def self.cached_popular(number_of_records = Constants::PROJECT_HOME_PAGE_LIMIT, exclude_ids = nil)
    Rails.cache.fetch([name, 'popular'], expires_in: 15.minutes) do
      exclude_ids ? Project.popular.where.not(id: exclude_ids).limit(number_of_records).to_a : Project.popular.limit(number_of_records).to_a
    end
  end

  # To be Expired on project completion
  def self.cached_completed(number_of_records = Constants::PROJECT_HOME_PAGE_LIMIT, exclude_ids = nil)
    #FIXME_AB: Please refactor this method along with similar others
    Rails.cache.fetch([name, 'completed'], expires_in: 15.minutes) do
      exclude_ids ? Project.completed.where.not(id: exclude_ids).limit(number_of_records).to_a : Project.completed.limit(number_of_records).to_a
    end
  end

  def expire_cache
    expire_recent_cache
    expire_completed_cache
    expire_popular_cache
  end

  def expire_recent_cache
    cached_recent_projects = Rails.cache.read([self.class.superclass.name, 'recent'])
    if (state_changed? && (%w(published unpublished successful failed).include? state)) ||
       (collected_amount_changed? && cached_recent_projects && cached_recent_projects.any? { |project| project.id == id })
      Rails.cache.delete([self.class.superclass.name, 'recent']) 
    end
  end

  def expire_popular_cache
    cached_popular_projects = Rails.cache.read([self.class.superclass.name, 'popular'])
    if cached_popular_projects && collected_amount_changed? && collected_amount > Project.min_collected_amount(cached_popular_projects)
      Rails.cache.delete([self.class.superclass.name, 'popular'])
    end
  end

  def expire_completed_cache
    Rails.cache.delete([self.class.superclass.name, 'completed']) if state_changed? && (%w(successful).include? state)
  end

  def self.min_collected_amount(projects)
    return 0 if projects.length <= 0
    projects.inject(projects.first.collected_amount || 0) { |memo, proj| proj.collected_amount < memo ? proj.collected_amount : memo }
  end


  # -------------- PROTECTED METHODS SECTION ------------------------
  # -----------------------------------------------------------------

  protected
    def set_time_to_midnight
      self.end_date = self.end_date.at_end_of_day
    end

    def sanitize_description
      self.description = (ActionController::Base.helpers.sanitize description, tags: %w(table tr td h1 h2 h3 h4 h5 h6 p ul ol li b strong em i blockquote span hr br), attributes: %w(id class style)).html_safe
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

    def refund_collected_amount
      contributions.where(state: ['accepted', 'contributed']).each do |contribution|
        contribution.refund!
      end
    end

end

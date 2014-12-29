class Project < ActiveRecord::Base

  # -------------- SECTION FOR ASSOCIATIONS ---------------------
  # -------------------------------------------------------------
  has_many :images, -> { where document: false }, as: :imageable
  has_many :legal_documents, -> { where document: true }, as: :imageable, class_name: 'Image'
  belongs_to :user
  has_attached_file :project_picture

  accepts_nested_attributes_for :images, :legal_documents

  after_validation :filter_images_error_messages
  before_create :set_time_to_midnight
  before_update :set_time_to_midnight
  
  # -------------- SECTION FOR VALIDATIONS ----------------------
  # -------------------------------------------------------------
  validates :type, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :amount_required, presence: true
  validates :min_amount_per_contribution, presence: true

  validates :end_date, presence: true, date: { greater_than_or_equal_to: (5.days.from_now.beginning_of_day) }
  validates :title, uniqueness: true
  validates :amount_required, numericality: { greater_than: 0, less_than_or_equal_to: 10000000 }
  validates :min_amount_per_contribution, numericality: { greater_than: 0, less_than_or_equal_to: :amount_required }

  validate :amount_multiple_of_100
  validate :min_amount_multiple_of_5
  validates_attachment_content_type :project_picture, content_type: %w(image/jpg image/jpeg image/png image/gif)

  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------
  scope :charity, -> { where(type: 'CharityProject') }
  scope :investment, -> { where(type: 'InvestmentProject') }
  scope :order_by_creation, -> { order(created_at: :desc) }
  scope :projects_to_be_approved, -> { where(verified_at: nil).order_by_creation }

  # To determine which all projects we can make
  def self.types
    %w(CharityProject InvestmentProject)
  end

  def amount_multiple_of_100
    errors[:amount_required] << 'should be a multiple of 100' if !(amount_required % 100 == 0)
  end

  def min_amount_multiple_of_5
    errors[:min_amount_per_contribution] << 'should be a multiple of 5' if !(amount_required % 5 == 0)
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

  protected
    def set_time_to_midnight
      self.end_date = self.end_date.at_end_of_day
    end

end

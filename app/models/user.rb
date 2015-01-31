class User < ActiveRecord::Base

  attr_accessor :missing_info_page
  
  # -------------- SECTION FOR ASSOCAITIONS ---------------------
  # -------------------------------------------------------------

  # Other options: :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :addresses, autosave: true
  has_attached_file :profile_picture, styles: { thumbnail: '128x128#' }
  has_attached_file :pan_card_copy, styles: { thumbnail: '60x60#' }

  has_many :projects, dependent: :restrict_with_error

  accepts_nested_attributes_for :addresses, reject_if: :all_blank, limit: 2

  has_many :contributions, -> { includes :project }
  has_many :project_contributions, through: :contributions, dependent: :restrict_with_error

  # -------------- SECTION FOR CALLBACKS ------------------------
  # -------------------------------------------------------------
  before_update :delete_pan_card_copy, if: :pan_card_changed?

  # -------------- SECTION FOR VALIDATIONS ----------------------
  # -------------------------------------------------------------

  validates_attachment_content_type :profile_picture, content_type: Constants::IMAGE_UPLOAD_FORMATS
  validates_attachment_content_type :pan_card_copy, content_type: Constants::IMAGE_UPLOAD_FORMATS
  validates :addresses, count: { limit: 2 }
  validates :pan_card, allow_blank: true, format: { with: Constants::PAN_REGEXP, message: 'should be in format AAA[ABCFGHLJPT]A9999A' }
  validates :phone_number, allow_blank: true, format: { with: /\A[0-9]{8,10}\Z/, message: 'should have 8 or 10 digits' }
  validates :first_name, presence: true, length: { in: 2..50 }
  
  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------

  scope :order_by_creation, -> { order(created_at: :desc) }

  def name
    [first_name, last_name].join(' ').presence || 'User'
  end

  # CALLBACK METHOD
  def delete_pan_card_copy
    self.pan_card_copy = nil
  end

  def pan_details_complete?
    !!(pan_card && pan_card_copy.exists?)
  end

  def pan_details_verified?
    !!pan_verified_at
  end

  def primary_address_details_complete?
    primary_address = addresses.primary_address
    !!(primary_address && primary_address.address_proof.exists?)
  end

  def primary_address_details_verified?
    primary_address = addresses.primary_address
    !!(primary_address && primary_address.verified_at)
  end

  def current_address_details_complete?
    current_address = addresses.current_address
    !!(current_address && current_address.address_proof.exists?)
  end

  def current_address_details_verified?
    current_address = addresses.current_address
    !!(current_address && current_address.verified_at)
  end

  def complete?
    if !pan_details_complete?
      @missing_info_page = :missing_pan
      false
    elsif !primary_address_details_complete?
      @missing_info_page = :missing_address
      false
    else
      true
    end   
  end

  def verified?
    pan_details_verified? && primary_address_details_verified?
  end

  def profile_projects(owner = false)
    grouped_projects = projects.order(updated_at: :desc).group_by { |project| project.state }
    categorized_projects = []
    states = %w(published payment_pending successful)
    states = %w(created published payment_pending successful unpublished failed) if owner
    states.each do |state| 
      categorized_projects << grouped_projects[state] if grouped_projects[state]
    end
    categorized_projects.flatten
  end

end

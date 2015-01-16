#FIXME_AB: No Database indexes. Please add to all tables. and Keep adding in future tables. You should take care of db indexes when you create/add table/field 
class User < ActiveRecord::Base

  attr_accessor :missing_info_page
  
  # -------------- SECTION FOR ASSOCAITIONS ---------------------
  # -------------------------------------------------------------

  # Other options: :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :addresses, autosave: true
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
  #FIXME_AB: %w(image/jpg image/jpeg image/png) is being repeated, please think a way out
  validates_attachment_content_type :pan_card_copy, content_type: %w(image/jpg image/jpeg image/png)
  #FIXME_AB: I think instead of having validation for two address. you should have permanent and current address address. and validation on them
  validates :addresses, count: { limit: 2 }
  validates :pan_card, allow_blank: true, format: { with: /\A[a-z]{3}[abcfghljpt]{1}[a-z]{1}[0-9]{4}[a-z]{1}\Z/i, message: 'should be in format AAA[ABCFGHLJPT]A9999A' }
  validates :phone_number, allow_blank: true, format: { with: /\A[0-9]{8,10}\Z/, message: 'should have 8 or 10 digits' }
  validates :first_name, presence: true, length: { in: 2..50 }
  
  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------

  scope :order_by_creation, -> { order(created_at: :desc) }

  def name
    [first_name, last_name].join(' ').presence || 'User'
  end

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
    !!primary_address.verified_at
  end

  def current_address_details_complete?
    current_address = addresses.current_address
    !!(current_address && current_address.address_proof.exists?)
  end

  def current_address_details_verified?
    current_address = addresses.current_address
    !!current_address.verified_at
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

  # Only admin can verify the user details
  def verify(admin, should_verify_current_address = false)
    verified = false

    unless pan_details_verified?
      verified = self.update(pan_verified_at: DateTime.current, pan_verified_by: admin.id)
    end
    
    unless primary_address_details_verified?
      verified = self.addresses.primary_address.update(verified_at: DateTime.current, admin_user_id: admin.id)
    end

    if should_verify_current_address
      verified = self.addresses.current_address.update(verified_at: DateTime.current, admin_user_id: admin.id)
    end

    verified
  end

end

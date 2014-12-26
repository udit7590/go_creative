class User < ActiveRecord::Base

  # -------------- SECTION FOR ASSOCAITIONS ---------------------
  # -------------------------------------------------------------

  # Other options: :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :addresses
  has_attached_file :pan_card_copy, styles: { thumbnail: '60x60#' }

  has_many :projects

  validates_attachment_content_type :pan_card_copy, content_type: %w(image/jpg image/jpeg image/png)

  accepts_nested_attributes_for :addresses,  reject_if: :all_blank, limit: 2

  # -------------- SECTION FOR CALLBACKS ------------------------
  # -------------------------------------------------------------
  before_update :delete_pan_card_copy, if: :pan_card_changed?

  # -------------- SECTION FOR VALIDATIONS ----------------------
  # -------------------------------------------------------------
  validates_attachment_content_type :pan_card_copy, content_type: %w(image/jpg image/jpeg image/png)
  validates :addresses, count: { limit: 2 }
  
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
    (pan_card && pan_card_copy) ? true : false
  end

  def primary_address_details_complete?
    primary_address = addresses.primary_address
    (primary_address && primary_address.address_proof.exists?) ? true : false
  end

  def current_address_details_complete?
    current_address = addresses.current_address
    (current_address && current_address.address_proof.exists?) ? true : false
  end

end

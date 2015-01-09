class Address < ActiveRecord::Base

  attr_accessor :same_as_primary

  # -------------- SECTION FOR ASSOCAITIONS ---------------------
  # -------------------------------------------------------------
  belongs_to :user
  has_attached_file :address_proof, styles: { thumbnail: '60x60#' }

  # -------------- SECTION FOR CALLBACKS ------------------------
  # -------------------------------------------------------------
  before_update :delete_address_proof, if: :full_address_changed?

  # -------------- SECTION FOR VALIDATIONS ----------------------
  # -------------------------------------------------------------
  
  validates :full_address, length: { maximum: 250 }
  validates :state, length: { maximum: 60 }
  validates :city, length: { maximum: 60 }
  #FIXME_AB: Content type array is being repeated
  validates_attachment_content_type :address_proof, content_type: %w(image/jpg image/jpeg image/png image/gif)

  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------
  #FIXME_AB: Why do we need this class method with is returning me the last address. Better suite as scope. Also the name should not have address as substring in it as the model name is Address
  def self.current_address
    where(primary: false).last
  end

  #FIXME_AB: same comment as in the current_address method
  def self.primary_address
    where(primary: true).last
  end

  def delete_address_proof
    self.address_proof = nil
  end

end

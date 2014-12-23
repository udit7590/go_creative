class Address < ActiveRecord::Base

  attr_accessor :same_as_primary

  # -------------- SECTION FOR ASSOCAITIONS ---------------------
  # -------------------------------------------------------------
  belongs_to :user
  has_attached_file :address_proof, styles: { thumbnail: '60x60#' }

  # -------------- SECTION FOR CALLBACKS ------------------------
  # -------------------------------------------------------------
  before_update :delete_address_proof, if: :changed?

  # -------------- SECTION FOR VALIDATIONS ----------------------
  # -------------------------------------------------------------
  validates_attachment_content_type :address_proof, content_type: %w(image/jpg image/jpeg image/png image/gif)

  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------
  def self.current_address
    where(primary: false).last
  end

  def self.primary_address
    where(primary: true).last
  end

  def delete_address_proof
    self.address_proof = nil
  end

end

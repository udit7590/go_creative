class Address < ActiveRecord::Base
  belongs_to :user

  attr_accessor :same_as_primary

  has_attached_file :address_proof, styles: { thumbnail: '60x60#' }

  validates_attachment_content_type :address_proof, content_type: %w(image/jpg image/jpeg image/png image/gif)

  def self.current_address
    where(primary: false).first
  end

  def self.primary_address
    where(primary: true).first
  end

end

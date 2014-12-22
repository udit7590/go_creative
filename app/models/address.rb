class Address < ActiveRecord::Base
  belongs_to :user

  scope :primary_address, -> { where(primary: true) }

  has_attached_file :primary_address_proof, styles: { thumbnail: '60x60#' }
  has_attached_file :current_address_proof, styles: { thumbnail: '60x60#' }


  validates_attachment :primary_address_proof, 
                        content_type: { content_type: %w(image/jpg image/jpeg image/png) },
                        size: { in: 0..2.megabytes }

  validates_attachment :current_address_proof, 
                        content_type: { content_type: %w(image/jpg image/jpeg image/png) },
                        size: { in: 0..2.megabytes }                        
end

class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true

  has_attached_file :image, styles: { thumbnail: '60x60#' }
  accepts_nested_attributes_for :imageable

  validates_attachment_content_type :image, content_type: %w(image/jpg image/jpeg image/png)
  validates_attachment_size :image, :less_than => 2.megabyte, 
                            :unless => Proc.new { |image| image.image_file_name.blank? }

  scope :documents, -> { where(document: true) }
end

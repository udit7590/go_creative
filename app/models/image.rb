class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true

  has_attached_file :image, styles: {
                              thumbnail: '270x220^'
                            },
                            convert_options: {
                              thumbnail: " -gravity center -crop '270x220+0+0'"
                            }
  accepts_nested_attributes_for :imageable

  validates_attachment_content_type :image, content_type: %w(image/jpg image/jpeg image/png), unless: :document?
  validates_attachment_content_type :image, content_type: %w(image/jpg image/jpeg image/png application/pdf), if: :document?
  validates_attachment_size :image, :less_than => 2.megabyte, 
                            :unless => Proc.new { |image| image.image_file_name.blank? }

  scope :documents, -> { where(document: true) }
end

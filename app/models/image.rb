#FIXME_AB: Just a thought, I think we can make it little more better. Can we name this model as Attachment model and then have two models inheritted with it. 1. image. 2. document. This way we can have a better association. Right now you have project has_many images where document is false. Which is kinda confusing. Give it a thought, we can discuss
class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true

  has_attached_file :image, 
                    styles: (lambda do |image|
                      unless image.instance.document?
                        { 
                          thumbnail: { geometry: '270x220^', quality: 80 },
                          large: { geometry: '770x', quality: 100 } 
                        }
                      end
                    end)

  accepts_nested_attributes_for :imageable

  validates_attachment_content_type :image, content_type: %w(image/jpg image/jpeg image/png), unless: :document?
  validates_attachment_content_type :image, content_type: %w(image/jpg image/jpeg image/png application/pdf), if: :document?
  validates_attachment_size :image, :less_than => 2.megabyte, 
                            :unless => Proc.new { |image| image.image_file_name.blank? }

  scope :documents, -> { where(document: true) }
end

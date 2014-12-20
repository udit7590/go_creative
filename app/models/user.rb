class User < ActiveRecord::Base

  scope :order_by_creation, -> { order(created_at: :desc) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :addresses
  has_attached_file :pan_card_copy, styles: { thumbnail: '60x60#' }

  validates_attachment_content_type :pan_card_copy, content_type: %w(image/jpg image/jpeg image/png)
  validates_attachment_file_name :pan_card_copy, matches: %w(/png\Z/ /jpe?g\Z/)

  accepts_nested_attributes_for :addresses,  reject_if: :all_blank, limit: 2
  
  def name
    [first_name, last_name].join(' ').presence || 'User'
  end

end

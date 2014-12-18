class User < ActiveRecord::Base

  scope :order_by_creation, -> { order(created_at: :desc) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :addresses

  def name
    [first_name, last_name].join(' ').presence || 'User'
  end

end

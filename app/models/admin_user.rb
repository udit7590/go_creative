class AdminUser < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

 def name
    [first_name, last_name].join(' ').presence || 'Admin'
  end
end

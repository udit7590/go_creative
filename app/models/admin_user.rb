class AdminUser < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

 def name
    [try(:first_name), try(:last_name)].join(' ').presence || 'Admin'
  end
end

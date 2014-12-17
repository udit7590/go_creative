class AdminUser < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

 def name
    if(first_name && last_name)
      first_name + ' ' + last_name
    elsif first_name
      first_name
    else
      'Admin'
    end
  end
end

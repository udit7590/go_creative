class User < ActiveRecord::Base
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  def name
    if(first_name && last_name)
      first_name + ' ' + last_name
    elsif first_name
      first_name
    else
      'User'
    end
  end

end

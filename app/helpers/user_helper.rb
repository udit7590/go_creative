module UserHelper
  def path_for_profile_picture(user)
    if user.profile_picture.present?
      user.profile_picture.url(:thumbnail)
    else
      'site/user_profile1.png'
    end
  end
end

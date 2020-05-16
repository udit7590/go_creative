module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      admin = FactoryBot.build(:admin)
      admin.save!(validate: false)
      sign_in admin
      @current_admin = admin
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryBot.build(:user)
      user.save!(validate: false)
      sign_in user
      @current_user = user
    end
  end
end

Gocreative::Application.routes.draw do

  root 'home#index'
  devise_for :users
  devise_for :admins, :controllers => { :sessions => "admin_area/sessions" }, :path => 'admin/', :path_names => {:sign_in => 'login', :sign_out => 'logout'}

  namespace :admin_area, path: 'admin' do
    root 'dashboard#index', controller: 'admin_area/dashboard'
    # resources :admin, only: [:show, :edit, :update]
  end

end

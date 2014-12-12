Gocreative::Application.routes.draw do

  root 'home#index'

  devise_for :users, controllers: { registrations: 'registrations' }

  devise_for :admin_users,
              controllers: { sessions: 'admin/sessions', passwords: 'admin/passwords'},
              path: 'admin',
              path_names: { sign_in: 'login', sign_out: 'logout' }

  namespace :admin do
    root 'dashboard#index', controller: 'admin/dashboard'
  end

end

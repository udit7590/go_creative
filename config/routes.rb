Gocreative::Application.routes.draw do

  root 'home#index'

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  devise_for :users, controllers: { 
                registrations: 'registrations', 
                confirmations: 'confirmations', 
                sessions: 'sessions', 
                passwords: 'passwords' 
              }

  devise_for :admin_users,
              controllers: { sessions: 'admin/sessions', passwords: 'admin/passwords' },
              path: 'admin',
              path_names: { sign_in: 'login', sign_out: 'logout' }

  namespace :admin do
    root 'dashboard#index', controller: 'admin/dashboard'
    resources :users, only: :index, concerns: :paginatable
  end

  #Singular resource for account
  resource :account, only: [:show, :edit, :destroy, :update] do
    # For PAN Card upload
    post :upload_pan_card_image

    # For Address proof upload
    post :upload_address_proof
  end

end

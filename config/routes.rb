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
    resources :projects, only: :index, concerns: :paginatable
  end

  #Singular resource for account
  resource :account, only: [:show, :edit, :destroy, :update] do
    # For PAN Card upload
    post :upload_pan_card_image

    # For Address proof upload
    post :upload_primary_address_proof
    post :upload_current_address_proof

    # For updating address and PAN details
    get :update_pan_details
    get :update_address_details
    patch :update_incomplete_details
  end

  resource :users do
    resources :projects, shallow: true do
      get :user_projects, path: 'my', on: :collection, as: 'current'
    end
  end

end

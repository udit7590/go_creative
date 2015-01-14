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
    resources :users, only: [:index, :show], concerns: :paginatable do
      post :verify
    end
    resources :projects, only: [:index, :show], concerns: :paginatable do
      get :publish
      get :unpublish
    end
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

  scope '/projects', as: 'projects' do
    get '/', to: 'projects#index'
    get :charity, to: 'projects#charity_projects'
    get :investment, to: 'projects#investment_projects'
    get :load_more, to: 'projects#load_more_projects'
  end

  resource :users do
    resources :projects, shallow: true, except: :index do
      get :user_projects, path: 'my', on: :collection, as: 'current'
      resources :comments, shallow: true, except: [:show, :update, :create] do
        get :delete
        get :undo_delete
        get :report_abuse
        get :load_more, to: 'comments#load_more', on: :collection
      end
    end
  end

end

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
      get :cancel
      collection do
        get :published, concerns: :paginatable
        get :initial, concerns: :paginatable
      end
    end
    resources :projects, shallow: true, only: [] do
      resources :comments, only: [:index, :new, :create, :destroy] do
        get :load_more, on: :collection
      end
    end
  end

  #Singular resource for account
  get ':id/profile', to: 'accounts#show', as: :profile
  resource :account, only: [:edit, :update] do

    # get ':id', to: 'accounts#show', as: :show
    # For PAN Card upload
    post :upload_pan_card_image

    # For Address proof upload
    post :upload_primary_address_proof
    post :upload_current_address_proof
    get :edit_profile_picture
    patch :upload_profile_picture

    # For updating address and PAN details
    get :update_pan_details
    get :update_address_details
    patch :update_incomplete_details
  end

  scope '/projects', as: 'projects' do
    get '/', to: 'projects#index'
    get :charity, to: 'projects#charity'
    get :investment, to: 'projects#investment'
    get :load_more, to: 'projects#load_more'
    get :completed, to: 'projects#completed'
  end

  resource :users do
    resources :projects, shallow: true, except: :index do
      get :user_projects, path: 'my', on: :collection, as: 'current'
      get :update_description 

      resources :comments, shallow: true, except: [:show, :update, :create] do
        get :delete
        get :undo_delete
        get :report_abuse
        get :load_more, to: 'comments#load_more', on: :collection
      end
      resources :contributions, shallow: true
    end
  end

end

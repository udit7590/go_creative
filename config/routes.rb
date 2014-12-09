Gocreative::Application.routes.draw do

  root 'home#index'
  devise_for :users

  namespace :admin do
    resources :users, only: [:show, :edit, :update]
  end

end

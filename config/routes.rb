Rails.application.routes.draw do
  devise_for :users
  get "carts/index"
  post '/add_to_cart/:id', to: 'products#add_to_cart', as: 'add_to_cart'
  root "pages#home"

  get "pages/home"
  get "pages/about"

  resources :users, only: [:show]
  resources :products, only: [:index, :show]
  resources :carts, only: [:index]

  resources :users, only: [:show] do
    post 'addresses', to: 'users#create_address', as: 'addresses'
    patch 'addresses/:address_id', to: 'users#update_address', as: 'address'
    delete 'addresses/:address_id', to: 'users#delete_address'
  end

  namespace :admin do
    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
    resources :products, only: [:destroy, :edit, :update, :new, :create]
    resources :categories, only: [:destroy, :edit, :update, :new, :create]
  end
end










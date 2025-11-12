Rails.application.routes.draw do
  devise_for :users
  get "carts/index"
  root "pages#home"

  get "pages/home"
  get "pages/about"

  resources :products, only: [:index, :show]
  resources :carts, only: [:index]

  namespace :admin do
    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
    resources :products, only: [:index, :destroy, :edit, :update, :new, :create]
  end
end
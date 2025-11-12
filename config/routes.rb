Rails.application.routes.draw do
  devise_for :users
  get "carts/index"
  root "pages#home"

  get "pages/home"
  get "pages/about"

  resources :products
  resources :carts, only: [:index]

  get 'admin/dashboard', to: 'admin#dashboard', as: 'admin_dashboard'

end

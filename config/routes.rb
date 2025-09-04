Rails.application.routes.draw do
  devise_for :admins, path: 'admin', controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations'
  }
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  root 'home#index'
  
  resources :cosmetic_formulations, only: [:index, :new, :create, :show]
  
  # Admin routes
  get '/admin', to: 'admin/home#index'
  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
  end

  # User dashboard routes
  get 'dashboard', to: 'users#show'
  get 'profile/edit', to:'users#edit'
  patch 'profile', to: 'users#update'
  put 'profile', to: 'users#update'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

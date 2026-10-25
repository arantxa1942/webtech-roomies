Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#home"

  resources :properties
  resources :listings
  resources :neighborhoods
  resources :applications
  resources :visits
  resources :reviews


end
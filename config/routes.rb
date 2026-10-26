Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#home"

  resources :properties
  resources :amenities
  resources :listings do 
    member do 
      patch :publish
      patch :withdraw
      patch :mark_rented
    end 
  end
  resources :neighborhoods
  resources :applications
  
  resources :properties do
    resources :reviews, only: %i[new create edit update destroy]
  end
  resource :current_user, only: :update
  resource :amenities
  resources :applications do
    member do
      patch :shortlist
      patch :reject
      patch :accept
      patch :withdraw
    end
  end
  resources :applications do
    resource :visit, only: %i[create update destroy] do
      patch :confirm
      patch :cancel
      patch :complete
    end
  end

end
<<<<<<< HEAD
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#home"

  resource :current_user, only: :update

  resources :neighborhoods
  resources :amenities

  resources :properties do
    resources :reviews, only: %i[new create edit update destroy]
  end

  resources :listings do
    member do
      patch :publish
      patch :withdraw
      patch :mark_rented
    end
    resources :applications, only: :create
  end

  resources :applications, only: %i[index show] do
    member do
      patch :shortlist
      patch :reject
      patch :accept
      patch :withdraw
    end

    resource :visit, only: %i[create update destroy] do
      member do
        patch :confirm
        patch :cancel
        patch :complete
      end
    end
  end
end
=======
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#home"
  resource :session, only: [:new, :create, :destroy]
  resources :properties
  resources :listings do
    resources :applications, only: [:create, :update, :destroy]
  end
  resources :neighborhoods
  resources :applications, only: [:index, :show]
  resources :visits
  resources :reviews
end
>>>>>>> f85dde4 (Assignment 4)

Rails.application.routes.draw do
  resource :session, only: [:new, :create, :destroy]
  resources :passwords, param: :token
  resources :users, only: %i[new create]
  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#home"
  resource :profile, only: %i[edit update]
  resources :neighborhoods
  resources :amenities

  resources :properties do
    resources :reviews, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :listings do
    member do
      patch :publish
      patch :withdraw
      patch :mark_rented
    end
    resources :applications, only: [:create]
    resources :reports, only: [:new, :create]
  end

  resources :applications, only: [:index, :show] do
    member do
      patch :shortlist
      patch :reject
      patch :accept
      patch :withdraw
    end
    resources :visits, only: [:create, :update] do
      member do
        patch :confirm
        patch :cancel 
        patch :complete
      end
    end
  end
  resources :reports, only: [:index] do
    member do
      patch :resolve
    end
  end

  namespace :api do
    namespace :v1 do
      resources :listings, only: %i[index show]
    end
  end
end
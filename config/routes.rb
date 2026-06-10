# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             class_name: 'User',
             path: 'api/v1/auth',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'api/v1/auth/sessions',
               registrations: 'api/v1/auth/registrations'
             },
             defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        get 'auth/me', to: 'auth/sessions#show'
      end

      namespace :users do
        resource :preferences, only: %i[show update]
      end

      resources :word_sets, only: %i[index show] do
        resources :words, only: [:index], module: :word_sets
      end
      resources :words, only: %i[index show]
      get :search, to: 'search#index'
    end
  end
end

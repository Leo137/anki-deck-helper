Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :word_sets, only: %i[index show] do
        resources :words, only: [:index], module: :word_sets
      end
      resources :words, only: %i[index show]
      get :search, to: 'search#index'
    end
  end
end

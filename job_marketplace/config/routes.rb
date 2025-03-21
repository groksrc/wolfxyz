Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      resources :opportunities, only: [:index, :create] do
        member do
          post :apply
        end
      end
    end
  end

  # Health checks
  get 'health' => 'health#check'

  # API Documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Sidekiq web interface
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end

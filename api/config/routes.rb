require "sidekiq/web"

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  mount Sidekiq::Web => "/sidekiq"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :auth do
        post "login", to: "sessions#create"
        post "refresh", to: "sessions#refresh"
      end
      namespace :organization do
        resources :companies, only: [ :index, :show ] do
          resources :clients, only: [ :create, :index ]
          resources :projects, only: [ :create, :index, :show ] do
            resources :versions, only: [ :index, :show ], controller: "project_versions"
            resources :completion_snapshots, only: [ :create ]
          end
        end
        resources :completion_snapshots, only: [ :show, :index, :update, :destroy ] do
          member do
            get :previous
            post :publish
            resource :invoice, only: [ :show ]
          end
        end
        resources :clients, only: [ :show ]
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end

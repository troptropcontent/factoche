require "sidekiq/web"

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  mount Sidekiq::Web => "/sidekiq"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :accounting do
    namespace :prints do
      get "/unpublished_invoices/:id", action: "unpublished_invoice", as: :unpublished_invoice
      get "/published_invoices/:id", action: "published_invoice", as: :published_invoice
      get "/credit_note/:id", action: "credit_note", as: :credit_note
    end
  end

  namespace :api, defaults: { format: :json } do
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
            post :cancel
            defaults format: :html do
              resource :invoice, only: [ :show ]
            end
          end
        end
        resources :project_versions do
          resources :completion_snapshots do
            collection do
              get :new_completion_snapshot_data
            end
          end
          namespace :invoices do
            post :completion_snapshot, to: "completion_snapshots#create"
          end
        end
        resources :clients, only: [ :show ]
        resources :projects do
          resources :invoices, only: [ :index, :show, :update, :create, :destroy ] do
            member do
              post "", action: :post
            end
          end
          member do
            get :invoiced_items
          end
        end
        resources :prints, only: [ :show ]
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end

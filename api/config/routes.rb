require "sidekiq/web"

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  mount Sidekiq::Web => "/sidekiq"
  mount ActionCable.server => "/cable"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :accounting do
    namespace :prints do
      get "/unpublished_invoices/:id", action: "unpublished_invoice", as: :unpublished_invoice
      get "/published_invoices/:id", action: "published_invoice", as: :published_invoice
      get "/credit_notes/:id", action: "credit_note", as: :credit_note
    end
  end

  resources :prints, only: [] do
    collection do
      get "quotes/:quote_id/quote_versions/:id", action: :quote_version, as: :quote
      get "draft_orders/:draft_order_id/draft_order_versions/:id", action: :draft_order_version, as: :draft_order
      get "orders/:order_id/order_versions/:id", action: :order_version, as: :order
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      namespace :auth do
        post "login", to: "sessions#create"
        post "refresh", to: "sessions#refresh"
      end
      namespace :organization do
        resources :companies, only: [ :index, :show, :update ] do
          resource :dashboard, only: [ :show ]
          resources :clients, only: [ :create, :index ] do
            resources :quotes, only: [ :create ]
          end
          resources :projects, only: [ :create, :index, :show ] do
            resources :completion_snapshots, only: [ :create ]
          end
          resources :quotes, only: [ :index ]
          resources :draft_orders, only: [ :index ]
          resources :orders, only: [ :index ] do
            resources :versions, only: [ :index, :show ], controller: "project_versions"
          end
          resources :proformas, only: [ :index ]
          resources :invoices, only: [ :index ]
          resources :credit_notes, only: [ :index ]
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
        resources :project_versions, only: [ :show ] do
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
        resources :prints, only: [ :show ]
        resources :draft_orders, only: [ :show, :update ] do
          member do
            post "convert_to_order"
          end
        end
        resources :orders, only: [ :show, :update ] do
          resources :proformas, only: [ :create ]
          member do
            get :invoiced_items
          end
        end
        resources :quotes, only: [ :show, :update ] do
          member do
            post "convert_to_draft_order"
          end
        end
        resources :proformas, only: [ :update, :show, :destroy ] do
          member do
            post "", action: :post
          end
        end
        resources :invoices, only: [ :show ] do
          member do
            post "cancel", action: :cancel
          end
        end
        resources :credit_notes, only: [ :show ]
        resources :payments, only: [ :create ]
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end

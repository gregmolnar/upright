Upright::Engine.routes.draw do
  resource :session, only: [ :new, :create, :destroy ]

  get "auth/:provider/callback", to: "sessions#create", as: :auth_callback

  resources :artifacts, only: :show
  resources :nodes, only: :index
  resources :probe_results, only: :index
end

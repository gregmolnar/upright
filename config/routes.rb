Upright::Engine.routes.draw do
  admin_subdomain = ->(request) {
    Upright.configuration.admin_subdomain == request.subdomain
  }

  site_subdomain = ->(request) {
    Upright.configuration.site_subdomains.include? request.subdomain
  }

  constraints admin_subdomain do
    root "sites#index", as: :admin_root

    resource :session, only: [ :new, :create ], as: :admin_session
    match "auth/:provider/callback", to: "sessions#create", as: :auth_callback, via: [ :get, :post ]

    namespace :dashboards do
      get :uptime
    end

    # Prometheus proxy
    post "prometheus/api/v1/otlp/v1/metrics", to: "prometheus_proxy#otlp"
    match "prometheus/*path", to: "prometheus_proxy#proxy", via: :all
    get "prometheus", to: "prometheus_proxy#proxy", as: :prometheus

    # Alertmanager proxy
    match "alertmanager/*path", to: "alertmanager_proxy#proxy", via: :all
    get "alertmanager", to: "alertmanager_proxy#proxy", as: :alertmanager
  end

  constraints site_subdomain do
    root "probe_results#index", as: :site_root
    resources :artifacts, only: :show, as: :site_artifacts
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  # Global routes (no subdomain constraint)
  resource :session, only: [ :destroy ]
  root "sites#index"
end

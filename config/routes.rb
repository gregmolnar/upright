Upright::Engine.routes.draw do
  # Subdomain constraints
  # Admin subdomain is always "app" - see Upright::Configuration::ADMIN_SUBDOMAIN
  admin_subdomain = ->(request) {
    request.subdomain == Upright.configuration.admin_subdomain
  }

  # Site subdomains are derived from configured sites (ams, nyc, sfo, etc.)
  site_subdomain = ->(request) {
    subdomain = request.subdomain.presence
    subdomain &&
      subdomain != Upright.configuration.admin_subdomain &&
      Upright.configuration.site_subdomains.include?(subdomain)
  }

  # Admin subdomain ("app") - authentication and observability proxies
  constraints admin_subdomain do
    root "sites#index", as: :admin_root

    resource :session, only: [ :new, :create ], as: :admin_session
    match "auth/:provider/callback", to: "sessions#create", as: :auth_callback, via: [ :get, :post ]

    # Dashboards
    scope :dashboards, as: :dashboard do
      get "uptime", to: "dashboards#uptime"
    end

    # Prometheus proxy
    post "prometheus/api/v1/otlp/v1/metrics", to: "prometheus_proxy#otlp"
    match "prometheus/*path", to: "prometheus_proxy#proxy", via: :all
    get "prometheus", to: "prometheus_proxy#proxy", as: :prometheus

    # Alertmanager proxy
    match "alertmanager/*path", to: "alertmanager_proxy#proxy", via: :all
    get "alertmanager", to: "alertmanager_proxy#proxy", as: :alertmanager
  end

  # Site subdomains (ams, nyc, sfo, etc.) - probe results, artifacts, and jobs
  constraints site_subdomain do
    root "probe_results#index", as: :site_root
    resources :artifacts, only: :show, as: :site_artifacts
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  # Global routes (no subdomain constraint)
  resource :session, only: [ :destroy ]
  root "sites#index"
end

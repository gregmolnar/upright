# Upright Configuration
# See: https://github.com/basecamp/upright
#
# This must load before OmniAuth middleware, hence the 0_ prefix

Upright.configure do |config|
  # Service identification
  config.service_name = "<%= Rails.application.class.module_parent_name.underscore %>"
  config.user_agent = "Upright/1.0"

  # Production hostname for subdomain routing (e.g., "my-app.com")
  config.hostname = "<%= app_domain %>"

  # Default probe timeout in seconds
  config.default_timeout = 10

  # Playwright browser server URL
  # config.playwright_server_url = ENV["PLAYWRIGHT_SERVER_URL"]

  # OpenTelemetry endpoint
  # config.otel_endpoint = ENV["OTEL_EXPORTER_OTLP_ENDPOINT"]

  # Authentication via OpenID Connect (Logto, Keycloak, Duo, Okta, etc.)
  # config.auth_provider = :openid_connect
  # config.auth_options = {
  #   issuer: ENV["OIDC_ISSUER"],
  #   client_id: ENV["OIDC_CLIENT_ID"],
  #   client_secret: ENV["OIDC_CLIENT_SECRET"]
  # }
  #
  # No authentication (internal networks only)
  config.auth_provider = nil
end

# URL options for subdomain routing
UPRIGHT_HOSTNAME = if Rails.env.production?
  Upright.configuration.hostname
else
  "#{Rails.application.class.module_parent_name.underscore.dasherize}.localhost"
end.freeze

DEFAULT_URL_OPTIONS = if Rails.env.production?
  { protocol: "https", host: "app.#{UPRIGHT_HOSTNAME}", domain: UPRIGHT_HOSTNAME }
else
  { protocol: "http", host: "app.#{UPRIGHT_HOSTNAME}", port: 3000, domain: UPRIGHT_HOSTNAME }
end.freeze

Rails.application.configure do
  config.action_controller.default_url_options = DEFAULT_URL_OPTIONS

  config.action_dispatch.tld_length = 1

  # Allow requests from subdomains and base domain
  config.hosts = [ /.*\.#{Regexp.escape(UPRIGHT_HOSTNAME)}/, UPRIGHT_HOSTNAME ]
end

Rails.application.config.after_initialize do
  Rails.application.routes.default_url_options = DEFAULT_URL_OPTIONS
  Upright::Engine.routes.default_url_options = DEFAULT_URL_OPTIONS
end

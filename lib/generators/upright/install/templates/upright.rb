# Upright Configuration
# See: https://github.com/basecamp/upright

Upright.configure do |config|
  # Service identification
  config.service_name = "<%= Rails.application.class.module_parent_name.underscore %>"
  config.user_agent = "Upright/1.0"

  # Production hostname for subdomain routing (e.g., "myapp.example.com")
  # Can also be set via UPRIGHT_HOSTNAME environment variable
  # config.hostname = "myapp.example.com"

  # Default probe timeout in seconds
  config.default_timeout = 10

  # Site configuration file path
  config.sites_config_path = Rails.root.join("config/sites.yml")

  # Playwright browser server URL (production only)
  # config.playwright_server_url = ENV["PLAYWRIGHT_SERVER_URL"]

  # OpenTelemetry endpoint
  # config.otel_endpoint = ENV["OTEL_EXPORTER_OTLP_ENDPOINT"]

  # Authentication (choose one):
  #
  # Option 1: OpenID Connect (Logto, Keycloak, etc.)
  # config.auth_provider = :openid_connect
  # config.auth_options = {
  #   issuer: ENV["OIDC_ISSUER"],
  #   client_id: ENV["OIDC_CLIENT_ID"],
  #   client_secret: ENV["OIDC_CLIENT_SECRET"]
  # }
  #
  # Option 2: Simple username/password
  # config.auth_provider = :identity
  #
  # Option 3: No authentication (internal networks only)
  config.auth_provider = nil
end

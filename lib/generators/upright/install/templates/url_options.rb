# URL options for subdomain routing
# This must load before OmniAuth middleware, hence the 0_ prefix
#
# Configure your production hostname via:
#   - Environment variable: UPRIGHT_HOSTNAME=myapp.example.com
#   - Or edit this file directly

UPRIGHT_HOSTNAME = if Rails.env.production?
  ENV.fetch("UPRIGHT_HOSTNAME", "<%= app_domain %>")
else
  "<%= app_name %>.localhost"
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

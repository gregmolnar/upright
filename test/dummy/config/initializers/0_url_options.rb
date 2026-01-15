DEFAULT_URL_OPTIONS = {
  protocol: "http",
  host: "app.upright.localhost",
  port: 3040,
  domain: "upright.localhost"
}.freeze

Rails.application.configure do
  config.action_controller.default_url_options = DEFAULT_URL_OPTIONS
  config.action_dispatch.tld_length = 1
  config.hosts = [ /.*\.upright.localhost/, "upright.localhost" ]
end

Rails.application.config.after_initialize do
  Rails.application.routes.default_url_options = DEFAULT_URL_OPTIONS
  Upright::Engine.routes.default_url_options = DEFAULT_URL_OPTIONS
end

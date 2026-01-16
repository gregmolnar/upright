class Upright::Configuration
  # Admin subdomain is always "app" - this is documented behavior
  ADMIN_SUBDOMAIN = "app"

  # Core settings
  attr_accessor :service_name
  attr_accessor :user_agent
  attr_accessor :default_timeout

  # Site configuration
  attr_accessor :sites_config_path

  # Storage paths
  attr_accessor :prometheus_dir
  attr_accessor :video_storage_dir
  attr_accessor :storage_state_dir
  attr_accessor :frozen_record_path

  # Playwright
  attr_accessor :playwright_server_url

  # Authentication
  attr_accessor :auth_provider
  attr_accessor :auth_options

  # Observability
  attr_accessor :otel_endpoint
  attr_accessor :prometheus_url
  attr_accessor :alert_webhook_url

  # Production hostname (e.g., "myapp.example.com")
  # Used to configure subdomain routing and allowed hosts
  attr_accessor :hostname

  def initialize
    @service_name = "upright"
    @user_agent = "Upright/1.0"
    @default_timeout = 10

    @prometheus_dir = nil
    @video_storage_dir = nil
    @storage_state_dir = nil
    @frozen_record_path = nil
    @sites_config_path = nil

    @playwright_server_url = ENV["PLAYWRIGHT_SERVER_URL"]
    @otel_endpoint = ENV["OTEL_EXPORTER_OTLP_ENDPOINT"]

    @auth_provider = nil
    @auth_options = {}

    @hostname = nil
  end

  def admin_subdomain
    ADMIN_SUBDOMAIN
  end

  def site_subdomains
    Upright.sites.map { |site| site.code.to_s }
  end

  # Returns the domain portion of the hostname for subdomain routing
  # Production: configured hostname (e.g., "myapp.example.com")
  # Development: "{service_name}.localhost"
  def domain
    if Rails.env.production?
      hostname || raise(ConfigurationError, "hostname must be configured for production")
    else
      "#{service_name}.localhost"
    end
  end

  # Returns default URL options hash for Rails routing
  # Use in config/initializers/0_url_options.rb:
  #   Rails.application.configure do
  #     config.action_controller.default_url_options = Upright.config.default_url_options
  #   end
  def default_url_options
    if Rails.env.production?
      { protocol: "https", host: "#{admin_subdomain}.#{domain}", domain: domain }
    else
      { protocol: "http", host: "#{admin_subdomain}.#{domain}", port: 3000, domain: domain }
    end
  end

  # Returns allowed hosts configuration for Rails
  # Use in config/initializers/0_url_options.rb:
  #   Rails.application.configure do
  #     config.hosts = Upright.config.allowed_hosts
  #   end
  def allowed_hosts
    [ /.*\.#{Regexp.escape(domain)}/, domain ]
  end

  def prometheus_dir
    @prometheus_dir || default_storage_path("prometheus")
  end

  def video_storage_dir
    @video_storage_dir || default_storage_path("playwright_videos")
  end

  def storage_state_dir
    @storage_state_dir || default_storage_path("playwright_storage_states")
  end

  def frozen_record_path
    @frozen_record_path || Rails.root.join("config/probes")
  end

  def sites_config_path
    @sites_config_path || Rails.root.join("config/sites.yml")
  end

  private
    def default_storage_path(subdir)
      if defined?(Rails) && Rails.root
        Rails.root.join("storage", subdir)
      else
        Pathname.new("storage").join(subdir)
      end
    end
end

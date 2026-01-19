class Upright::Configuration
  # Admin subdomain is always "app" - this is documented behavior
  ADMIN_SUBDOMAIN = "app"

  # Core settings
  attr_accessor :service_name
  attr_accessor :user_agent
  attr_accessor :default_timeout
  attr_accessor :hostname

  # Storage paths
  attr_accessor :prometheus_dir
  attr_accessor :video_storage_dir
  attr_accessor :storage_state_dir
  attr_accessor :frozen_record_path

  # Probe and authenticator paths (for auto-loading app-specific code)
  attr_writer :probes_path
  attr_writer :authenticators_path

  # Playwright
  attr_accessor :playwright_server_url

  # Authentication
  attr_accessor :auth_provider
  attr_accessor :auth_options

  # Observability
  attr_accessor :otel_endpoint
  attr_accessor :prometheus_url
  attr_accessor :alert_webhook_url

  def initialize
    @service_name = "upright"
    @user_agent = "Upright/1.0"
    @default_timeout = 10

    @prometheus_dir = nil
    @video_storage_dir = nil
    @storage_state_dir = nil
    @frozen_record_path = nil
    @probes_path = nil
    @authenticators_path = nil

    @playwright_server_url = ENV["PLAYWRIGHT_SERVER_URL"]
    @otel_endpoint = ENV["OTEL_EXPORTER_OTLP_ENDPOINT"]

    @auth_provider = nil
    @auth_options = {}
  end

  def admin_subdomain
    ADMIN_SUBDOMAIN
  end

  def site_subdomains
    Upright.sites.map { |site| site.code.to_s }
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

  def probes_path
    @probes_path || Rails.root.join("probes")
  end

  def authenticators_path
    @authenticators_path || Rails.root.join("probes/authenticators")
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

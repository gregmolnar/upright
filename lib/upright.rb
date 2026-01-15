require "frozen_record"
require "opentelemetry-sdk"
require "opentelemetry-exporter-otlp"
require "typhoeus"
require "solid_queue"
require "mission_control/jobs"
require "omniauth"
require "omniauth_openid_connect"
require "omniauth/rails_csrf_protection"
require "propshaft"
require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"
require "geared_pagination"
require "geohash_ruby"
require "yabeda/prometheus"
require "yabeda/puma/plugin"
require "upright/version"
require "upright/configuration"
require "upright/site"
require "upright/metrics"
require "upright/tracing"
require "upright/engine"

module Upright
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
      @sites = nil
    end

    # Load sites from YAML configuration
    def sites
      @sites ||= load_sites
    end

    def reload_sites!
      @sites = load_sites
    end

    # Find a site by code
    def find_site(code)
      sites.find { |site| site.code.to_s == code.to_s }
    end

    # Get the current site based on SITE_CODE env var
    def current_site
      find_site(ENV["SITE_CODE"]) || sites.first
    end

    # Get the primary site
    def primary_site
      sites.find(&:primary?) || sites.first
    end

    private
      def load_sites
        config_path = configuration.sites_config_path

        if config_path && File.exist?(config_path)
          yaml = YAML.load_file(config_path, permitted_classes: [ Symbol ])
          site_data = yaml["sites"] || yaml[:sites] || []

          site_data.map.with_index do |data, index|
            Site.new(
              code: data["code"] || data[:code],
              city: data["city"] || data[:city],
              country: data["country"] || data[:country],
              geohash: data["geohash"] || data[:geohash],
              provider: data["provider"] || data[:provider],
              host: data["host"] || data[:host],
              primary: data["primary"] || data[:primary] || false,
              stagger_index: data["stagger_index"] || data[:stagger_index] || index
            )
          end
        else
          # Fallback to environment variables for single-site deployments
          [
            Site.new(
              code: ENV.fetch("SITE_CODE", "default"),
              city: ENV["SITE_CITY"],
              country: ENV["SITE_COUNTRY"],
              geohash: ENV["SITE_GEOHASH"],
              provider: ENV["SITE_PROVIDER"],
              primary: true,
              stagger_index: 0
            )
          ]
        end
      end
  end

end

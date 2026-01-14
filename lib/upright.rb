require "frozen_record"
require "upright/version"
require "upright/configuration"
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
          yaml = YAML.load_file(config_path, permitted_classes: [Symbol])
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

  # Simple site data class
  class Site
    attr_reader :code, :city, :country, :geohash, :host, :stagger_index

    def initialize(code:, city: nil, country: nil, geohash: nil, provider: nil, host: nil, primary: false, stagger_index: 0)
      @code = code.to_sym
      @city = city
      @country = country
      @geohash = geohash
      @provider = provider
      @host = host
      @primary = primary
      @stagger_index = stagger_index
    end

    def provider
      @provider.to_s.inquiry
    end

    def primary?
      @primary
    end

    def default_timeout
      Upright.configuration.default_timeout
    end

    def to_h
      {
        code: code,
        city: city,
        country: country,
        geohash: geohash,
        provider: provider,
        host: host,
        primary: primary?,
        stagger_index: stagger_index
      }
    end
  end
end

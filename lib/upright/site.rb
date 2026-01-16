require "geohash_ruby"

module Upright
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

    def latitude
      coordinates.first
    end

    def longitude
      coordinates.last
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

    private
      def coordinates
        @coordinates ||= Geohash.decode(geohash).first
      end
  end
end

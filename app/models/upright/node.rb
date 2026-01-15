class Upright::Node
  class << self
    def all
      @all ||= begin
        nodes = deploy_config.dig("servers", "web", "hosts") || []
        nodes.flat_map do |node_config|
          node_config.map do |hostname, tags|
            new(hostname: hostname, tags: tags)
          end
        end
      end
    end

    def find_by_subdomain(subdomain)
      all.find { |node| node.subdomain == subdomain }
    end

    def tag_config
      @tag_config ||= deploy_config.dig("env", "tags") || {}
    end

    def reset!
      @all = nil
      @tag_config = nil
      @deploy_config = nil
    end

    private
      def deploy_config
        @deploy_config ||= YAML.load_file(Rails.root.join("config/deploy.yml"))
      end
  end

  attr_reader :hostname, :tags

  def initialize(hostname:, tags:)
    @hostname = hostname
    @tags = tags
  end

  def subdomain
    hostname.split(".").first
  end

  def site
    Upright::Site.new(
      code:     tag_data["SITE_CODE"],
      city:     tag_data["SITE_CITY"],
      country:  tag_data["SITE_COUNTRY"],
      geohash:  tag_data["SITE_GEOHASH"],
      provider: tag_data["SITE_PROVIDER"]
    )
  end

  def url
    Upright::Engine.routes.url_helpers.root_url(subdomain: subdomain)
  end

  def to_leaflet
    { hostname: hostname, city: site.city, geohash: site.geohash, url: url }
  end

  private
    def tag_data
      self.class.tag_config[@tags.first] || {}
    end
end

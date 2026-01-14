require "net/http"
require "json"
require "resolv"
require "geohash_ruby"

module Upright
  module Traceroute
    class IpMetadataLookup
      API_URL = "http://ip-api.com/batch"
      TIMEOUT = 5.seconds
      GEOHASH_PRECISION = 6
      CACHE_TTL = 24.hours

      class << self
        def for_many(ips)
          results, uncached_ips = partition_cached(ips)

          if uncached_ips.any?
            fetch_batch(uncached_ips).each do |ip, metadata|
              cache_write(ip, metadata)
              results[ip] = metadata
            end
          end

          results
        end

        def clear_cache
          cache.clear
        end

        private
          def partition_cached(ips)
            results = {}
            uncached = []

            valid_ips(ips).each do |ip|
              cached = cache_read(ip)
              if cached
                results[ip] = cached
              else
                uncached << ip
              end
            end

            [ results, uncached ]
          end

          def valid_ips(ips)
            ips.compact.uniq.select { |ip| ip =~ Resolv::IPv4::Regex }
          end

          def fetch_batch(ips)
            uri = URI(API_URL)
            request = Net::HTTP::Post.new(uri)
            request.content_type = "application/json"
            request.body = ips.to_json

            response = Net::HTTP.start(uri.hostname, uri.port, read_timeout: TIMEOUT, open_timeout: TIMEOUT) do |http|
              http.request(request)
            end

            if response.is_a?(Net::HTTPSuccess)
              parse_response(JSON.parse(response.body))
            else
              {}
            end
          end

          def parse_response(results)
            results.select { |result| result["status"] == "success" }.to_h do |result|
              [ result["query"], build_metadata(result) ]
            end
          end

          def build_metadata(result)
            {
              as: result["as"],
              isp: result["isp"],
              city: result["city"],
              country: result["country"],
              country_code: result["countryCode"],
              geohash: encode_geohash(result["lat"], result["lon"])
            }
          end

          def encode_geohash(latitude, longitude)
            if latitude && longitude
              Geohash.encode(latitude, longitude, GEOHASH_PRECISION)
            end
          end

          def cache_read(ip)
            cache.read("traceroute/ip_metadata/#{ip}")
          end

          def cache_write(ip, metadata)
            cache.write("traceroute/ip_metadata/#{ip}", metadata, expires_in: CACHE_TTL)
          end

          def cache
            @cache ||= if Rails.env.test?
              ActiveSupport::Cache::MemoryStore.new
            else
              ActiveSupport::Cache::FileStore.new(Rails.root.join("storage/ip_metadata"))
            end
          end
      end
    end
  end
end

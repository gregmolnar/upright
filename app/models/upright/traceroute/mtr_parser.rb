require "json"
require "resolv"

module Upright
  module Traceroute
    class MtrParser
      def initialize(json_output)
        @json_output = json_output
      end

      def parse
        data = JSON.parse(@json_output)
        hubs = data.dig("report", "hubs").to_a

        hubs.map { |hub| parse_hub(hub) }
      end

      private
        def parse_hub(hub)
          {
            **ip_and_hostname(hub["host"]),
            hop_number: hub["count"],
            loss_percent: hub["Loss%"],
            last_ms: hub["Last"],
            avg_ms: hub["Avg"],
            best_ms: hub["Best"],
            worst_ms: hub["Wrst"],
            stddev_ms: hub["StDev"]
          }
        end

        def ip_and_hostname(host)
          if host.nil? || host == "???"
            { ip: nil, hostname: nil }
          elsif ip_address?(host)
            { ip: host, hostname: nil }
          else
            { ip: resolve_ip(host), hostname: host }
          end
        end

        def resolve_ip(hostname)
          Resolv.getaddress(hostname) rescue nil
        end

        def ip_address?(address)
          address.match?(Resolv::IPv4::Regex)
        end
    end
  end
end

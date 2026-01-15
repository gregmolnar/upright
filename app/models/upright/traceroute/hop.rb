class Upright::Traceroute::Hop
  attr_reader :number, :ip, :loss_percent,
              :last_ms, :avg_ms, :best_ms, :worst_ms, :stddev_ms,
              :hostname, :as, :isp, :city, :country, :country_code, :geohash

  def initialize(hop_number: nil, ip: nil, hostname: nil, loss_percent: nil,
                 last_ms: nil, avg_ms: nil, best_ms: nil, worst_ms: nil, stddev_ms: nil,
                 as: nil, isp: nil, city: nil, country: nil, country_code: nil, geohash: nil)
    @number = hop_number
    @ip = ip
    @hostname = hostname
    @loss_percent = loss_percent
    @last_ms = last_ms
    @avg_ms = avg_ms
    @best_ms = best_ms
    @worst_ms = worst_ms
    @stddev_ms = stddev_ms
    @as = as
    @isp = isp
    @city = city
    @country = country
    @country_code = country_code
    @geohash = geohash
  end

  def responded?
    ip.present?
  end

  def high_packet_loss?
    loss_percent && loss_percent > 50
  end

  def any_packet_loss?
    loss_percent && loss_percent > 0
  end

  def display_name
    if responded?
      if isp.present?
        isp
      else
        ip
      end
    else
      "???"
    end
  end
end

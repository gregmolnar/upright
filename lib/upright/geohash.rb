module Upright
  module Geohash
    BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz"

    module_function

    def decode(geohash)
      bounds = [[-90.0, +90.0], [-180.0, +180.0]]

      geohash.downcase.each_char.with_index do |c, i|
        d = BASE32.index c

        5.times do |j|
          bit = (d & (1 << (4 - j))) >> (4 - j)
          k = (~i & 1) ^ (j & 1)
          bounds[k][bit ^ 1] = (bounds[k][0] + bounds[k][1]) / 2
        end
      end

      bounds.transpose
    end

    def encode(latitude, longitude, precision = 12)
      mids = [latitude, longitude]
      bounds = [[-90.0, +90.0], [-180.0, +180.0]]

      geohash = +""

      precision.times do |i|
        d = 0

        5.times do |j|
          k = (~i & 1) ^ (j & 1)
          mid = (bounds[k][0] + bounds[k][1]) / 2
          bit = mids[k] > mid ? 1 : 0
          bounds[k][bit ^ 1] = mid
          d |= bit << (4 - j)
        end

        geohash << BASE32[d]
      end

      geohash
    end
  end
end

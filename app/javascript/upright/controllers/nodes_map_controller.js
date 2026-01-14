import { Controller } from "@hotwired/stimulus"
import * as L from "leaflet"

// Geohash decoding (based on https://www.movable-type.co.uk/scripts/geohash.html)
const BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz"

function decodeGeohash(geohash) {
  let bounds = { sw: { lat: -90, lon: -180 }, ne: { lat: 90, lon: 180 } }
  let isLon = true

  for (const char of geohash.toLowerCase()) {
    const idx = BASE32.indexOf(char)
    for (let bit = 4; bit >= 0; bit--) {
      const mid = isLon
        ? (bounds.sw.lon + bounds.ne.lon) / 2
        : (bounds.sw.lat + bounds.ne.lat) / 2

      if (idx & (1 << bit)) {
        if (isLon) bounds.sw.lon = mid
        else bounds.sw.lat = mid
      } else {
        if (isLon) bounds.ne.lon = mid
        else bounds.ne.lat = mid
      }
      isLon = !isLon
    }
  }

  return {
    lat: (bounds.sw.lat + bounds.ne.lat) / 2,
    lon: (bounds.sw.lon + bounds.ne.lon) / 2
  }
}

export default class extends Controller {
  static values = { nodes: Array }

  connect() {
    const map = L.map(this.element, { scrollWheelZoom: false }).setView([30, 0], 2)
    const isDark = window.matchMedia("(prefers-color-scheme: dark)").matches

    const tiles = isDark
      ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
      : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"

    L.tileLayer(tiles, {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>'
    }).addTo(map)

    for (const node of this.nodesValue) {
      const { lat, lon } = decodeGeohash(node.geohash)
      L.marker([lat, lon])
        .addTo(map)
        .bindPopup(`<strong>${node.hostname}</strong><br>${node.city}`)
        .on("mouseover", function() { this.openPopup() })
        .on("mouseout", function() { this.closePopup() })
        .on("click", () => window.location.href = node.url)
    }
  }
}

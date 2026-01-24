import { Controller } from "@hotwired/stimulus"
import * as L from "leaflet"

export default class extends Controller {
  static values = { sites: Array }

  connect() {
    const map = L.map(this.element, { scrollWheelZoom: false }).setView([30, 0], 2)

    L.tileLayer(this.tileUrl, { attribution: this.attribution }).addTo(map)

    for (const site of this.sitesValue) {
      if (!site.lat || !site.lon) continue

      L.marker([site.lat, site.lon])
        .addTo(map)
        .bindPopup(`<strong>${site.hostname}</strong><br>${site.city}`)
        .on("mouseover", function() { this.openPopup() })
        .on("mouseout", function() { this.closePopup() })
        .on("click", () => window.location.href = site.url)
    }
  }

  get tileUrl() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
      : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
  }

  get attribution() {
    return '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>'
  }
}

import { Controller } from "@hotwired/stimulus"
import * as L from "leaflet"

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
      if (!node.lat || !node.lon) continue

      L.marker([node.lat, node.lon])
        .addTo(map)
        .bindPopup(`<strong>${node.hostname}</strong><br>${node.city}`)
        .on("mouseover", function() { this.openPopup() })
        .on("mouseout", function() { this.closePopup() })
        .on("click", () => window.location.href = node.url)
    }
  }
}

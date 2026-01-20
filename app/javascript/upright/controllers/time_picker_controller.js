import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = { range: { type: String, default: "24h" } }

  connect() {
    this.updateActiveButton()
    this.dispatch("change", { detail: this.timeParams })
  }

  select(event) {
    this.rangeValue = event.currentTarget.dataset.range
    this.updateActiveButton()
    this.dispatch("change", { detail: this.timeParams })
  }

  updateActiveButton() {
    this.buttonTargets.forEach(button => {
      button.classList.toggle("active", button.dataset.range === this.rangeValue)
    })
  }

  get timeParams() {
    const now = Math.floor(Date.now() / 1000)
    const duration = this.rangeToDuration(this.rangeValue)
    const start = now - duration

    return {
      range: this.rangeValue,
      start: start,
      end: now,
      step: this.calculateStep(duration)
    }
  }

  rangeToDuration(range) {
    const units = {
      h: 3600,
      d: 86400
    }
    const match = range.match(/^(\d+)([hd])$/)
    if (match) {
      return parseInt(match[1]) * units[match[2]]
    }
    return 86400 // default to 24h
  }

  calculateStep(duration) {
    // Target roughly 100-200 data points
    if (duration <= 3600) return 60          // 1h: 1min steps
    if (duration <= 21600) return 300        // 6h: 5min steps
    if (duration <= 86400) return 900        // 24h: 15min steps
    if (duration <= 604800) return 3600      // 7d: 1h steps
    return 14400                              // 30d: 4h steps
  }
}

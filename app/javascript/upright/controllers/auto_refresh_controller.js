import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { interval: { type: Number, default: 60000 } }

  connect() {
    this.startRefreshing()
    document.addEventListener("visibilitychange", this.handleVisibilityChange)
  }

  disconnect() {
    this.stopRefreshing()
    document.removeEventListener("visibilitychange", this.handleVisibilityChange)
  }

  startRefreshing() {
    this.timer = setInterval(() => this.refresh(), this.intervalValue)
  }

  stopRefreshing() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  refresh() {
    if (this.element.tagName === "TURBO-FRAME" && this.element.src) {
      this.element.reload()
    } else if (this.element.tagName === "TURBO-FRAME") {
      // Frame without explicit src reloads from current URL
      this.element.src = window.location.href
      this.element.reload()
    }
  }

  handleVisibilityChange = () => {
    if (document.hidden) {
      this.stopRefreshing()
    } else {
      this.refresh()
      this.startRefreshing()
    }
  }
}

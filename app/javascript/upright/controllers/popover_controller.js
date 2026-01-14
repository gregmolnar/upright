import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]

  loadFrame() {
    if (this.element.open && this.hasFrameTarget) {
      this.frameTarget.loading = "eager"
    }
  }

  close() {
    this.element.removeAttribute("open")
  }
}

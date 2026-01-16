import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["popover"]

  openArtifact(event) {
    if (event.target.closest("details, a, button")) return

    const row = event.target.closest("tr")
    const popover = this.popoverTargets.find(p => row.contains(p))

    if (popover) {
      popover.open = true
    }
  }
}

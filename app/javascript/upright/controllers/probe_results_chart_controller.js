import { Controller } from "@hotwired/stimulus"
import { Chart } from "frappe-charts"

export default class extends Controller {
  static values = { results: Array }

  connect() {
    this.results = this.resultsValue.slice().reverse()

    if (this.results.length > 0) {
      this.renderChart()
    }
  }

  renderChart() {
    new Chart(this.element, {
      data: this.chartData,
      type: "line",
      height: 200,
      colors: this.colors,
      lineOptions: { hideDots: 0, dotSize: 3, regionFill: 0 },
      axisOptions: { xAxisMode: "tick", xIsSeries: true },
      tooltipOptions: {
        formatTooltipX: d => this.tooltipLabels[this.labels.indexOf(d)] || d,
        formatTooltipY: d => d ? `${d.toFixed(3)}s` : null
      }
    })
  }

  get chartData() {
    return { labels: this.labels, datasets: this.datasets }
  }

  get labels() {
    return this._labels ||= this.results.map(r => this.formatTime(r.created_at))
  }

  get tooltipLabels() {
    return this._tooltipLabels ||= this.results.map(r => `${r.probe_name} @ ${this.formatTime(r.created_at)}`)
  }

  get datasets() {
    const datasets = []
    if (this.hasOkResults) datasets.push({ name: "Ok", values: this.okData, chartType: "line" })
    if (this.hasFailResults) datasets.push({ name: "Fail", values: this.failData, chartType: "line" })
    return datasets
  }

  get colors() {
    const colors = []
    if (this.hasOkResults) colors.push(this.isDarkMode ? "#4ade80" : "#22c55e")
    if (this.hasFailResults) colors.push(this.isDarkMode ? "#f87171" : "#ef4444")
    return colors
  }

  get okData() {
    return this._okData ||= this.results.map(r => r.status === "ok" ? r.duration : null)
  }

  get failData() {
    return this._failData ||= this.results.map(r => r.status !== "ok" ? r.duration : null)
  }

  get hasOkResults() {
    return this.okData.some(d => d !== null)
  }

  get hasFailResults() {
    return this.failData.some(d => d !== null)
  }

  get isDarkMode() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
  }

  formatTime(timestamp) {
    return new Date(timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
  }
}

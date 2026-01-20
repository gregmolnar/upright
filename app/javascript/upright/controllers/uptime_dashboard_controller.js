import { Controller } from "@hotwired/stimulus"
import { Chart } from "frappe-charts"

export default class extends Controller {
  static targets = ["summary", "chart", "table", "loading", "siteFilter", "typeFilter"]
  static values = { prometheusUrl: String }

  connect() {
    this.timeParams = null
    this.chart = null
  }

  onTimeChange(event) {
    this.timeParams = event.detail
    this.fetchData()
  }

  onFilterChange() {
    if (this.timeParams) {
      this.fetchData()
    }
  }

  async fetchData() {
    if (!this.timeParams) return

    this.showLoading()

    const siteCode = this.siteFilterTarget.value
    const probeType = this.typeFilterTarget.value

    const query = this.buildQuery(siteCode, probeType)
    const url = this.buildUrl(query)

    try {
      const response = await fetch(url)
      const data = await response.json()

      if (data.status === "success") {
        this.renderDashboard(data.data.result)
      } else {
        this.showError("Failed to fetch data")
      }
    } catch (error) {
      this.showError(`Error: ${error.message}`)
    } finally {
      this.hideLoading()
    }
  }

  buildQuery(siteCode, probeType) {
    const filters = []
    if (siteCode) filters.push(`site_code="${siteCode}"`)
    if (probeType) filters.push(`type="${probeType}"`)

    const labelSelector = filters.length > 0 ? `{${filters.join(",")}}` : ""
    return `avg by (name, type) (avg_over_time(upright_probe_up${labelSelector}[${this.timeParams.range}])) * 100`
  }

  buildUrl(query) {
    const params = new URLSearchParams({
      query: query,
      start: this.timeParams.start,
      end: this.timeParams.end,
      step: this.timeParams.step
    })
    return `${this.prometheusUrlValue}/api/v1/query_range?${params}`
  }

  renderDashboard(results) {
    this.renderSummary(results)
    this.renderChart(results)
    this.renderTable(results)
  }

  renderSummary(results) {
    if (results.length === 0) {
      this.summaryTarget.innerHTML = this.noDataHtml()
      return
    }

    const overallUptime = this.calculateOverallUptime(results)
    const colorClass = this.uptimeColorClass(overallUptime)

    this.summaryTarget.innerHTML = `
      <div class="uptime-card ${colorClass}">
        <div class="uptime-value">${overallUptime.toFixed(2)}%</div>
        <div class="uptime-label">Overall Uptime</div>
        <div class="uptime-period">${this.timeParams.range}</div>
      </div>
    `
  }

  renderChart(results) {
    if (results.length === 0) {
      this.chartTarget.innerHTML = ""
      return
    }

    const chartData = this.prepareChartData(results)

    if (this.chart) {
      this.chart.destroy()
    }

    this.chart = new Chart(this.chartTarget, {
      data: chartData,
      type: "line",
      height: 250,
      colors: this.chartColors(results.length),
      lineOptions: { hideDots: 1, regionFill: 0 },
      axisOptions: { xAxisMode: "tick", xIsSeries: true },
      tooltipOptions: {
        formatTooltipX: d => d,
        formatTooltipY: d => d ? `${d.toFixed(2)}%` : null
      }
    })
  }

  renderTable(results) {
    if (results.length === 0) {
      this.tableTarget.innerHTML = this.noDataTableHtml()
      return
    }

    const rows = results.map(result => {
      const name = result.metric.name || "Unknown"
      const type = result.metric.type || "Unknown"
      const uptime = this.calculateSeriesUptime(result.values)
      const colorClass = this.uptimeColorClass(uptime)

      return `
        <tr>
          <td><span class="probe-type-badge">${type}</span></td>
          <td class="probe-name">${name}</td>
          <td class="${colorClass}">${uptime.toFixed(2)}%</td>
        </tr>
      `
    }).join("")

    this.tableTarget.innerHTML = `
      <table class="uptime-table">
        <thead>
          <tr>
            <th>Type</th>
            <th>Probe</th>
            <th>Uptime</th>
          </tr>
        </thead>
        <tbody>${rows}</tbody>
      </table>
    `
  }

  prepareChartData(results) {
    // Get all unique timestamps across all series
    const allTimestamps = new Set()
    results.forEach(result => {
      result.values.forEach(([timestamp]) => {
        allTimestamps.add(timestamp)
      })
    })

    const sortedTimestamps = Array.from(allTimestamps).sort((a, b) => a - b)
    const labels = sortedTimestamps.map(ts => this.formatTimestamp(ts))

    const datasets = results.map(result => {
      const valueMap = new Map(result.values.map(([ts, val]) => [ts, parseFloat(val)]))
      const values = sortedTimestamps.map(ts => valueMap.get(ts) || null)

      return {
        name: result.metric.name || "Unknown",
        values: values,
        chartType: "line"
      }
    })

    return { labels, datasets }
  }

  calculateOverallUptime(results) {
    if (results.length === 0) return 0

    const uptimes = results.map(r => this.calculateSeriesUptime(r.values))
    return uptimes.reduce((sum, u) => sum + u, 0) / uptimes.length
  }

  calculateSeriesUptime(values) {
    if (values.length === 0) return 0
    const sum = values.reduce((acc, [, val]) => acc + parseFloat(val), 0)
    return sum / values.length
  }

  uptimeColorClass(percentage) {
    if (percentage >= 99.9) return "uptime-excellent"
    if (percentage >= 99) return "uptime-good"
    if (percentage >= 95) return "uptime-warning"
    return "uptime-critical"
  }

  chartColors(count) {
    const palette = [
      this.isDarkMode ? "#4ade80" : "#22c55e",
      this.isDarkMode ? "#60a5fa" : "#3b82f6",
      this.isDarkMode ? "#c084fc" : "#8b5cf6",
      this.isDarkMode ? "#f472b6" : "#ec4899",
      this.isDarkMode ? "#fb923c" : "#f97316",
      this.isDarkMode ? "#fbbf24" : "#eab308"
    ]
    return palette.slice(0, Math.min(count, palette.length))
  }

  formatTimestamp(timestamp) {
    const date = new Date(timestamp * 1000)
    const range = this.timeParams.range

    if (range.includes("d") && parseInt(range) > 1) {
      return date.toLocaleDateString([], { month: "short", day: "numeric" })
    }
    return date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
  }

  noDataHtml() {
    return `
      <div class="uptime-card uptime-no-data">
        <div class="uptime-value">—</div>
        <div class="uptime-label">No Data</div>
      </div>
    `
  }

  noDataTableHtml() {
    return `
      <div class="no-data-message">
        No probe data available for the selected filters and time range.
      </div>
    `
  }

  showLoading() {
    this.loadingTarget.classList.remove("hidden")
  }

  hideLoading() {
    this.loadingTarget.classList.add("hidden")
  }

  showError(message) {
    this.summaryTarget.innerHTML = `<div class="error-message">${message}</div>`
    this.chartTarget.innerHTML = ""
    this.tableTarget.innerHTML = ""
  }

  get isDarkMode() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
  }
}

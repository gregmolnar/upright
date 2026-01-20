import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["heatmap", "errorList", "loading", "siteFilter", "probeFilter"]
  static values = { prometheusUrl: String }

  connect() {
    this.timeParams = null
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
    const probeName = this.probeFilterTarget.value

    const query = this.buildQuery(siteCode, probeName)
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

  buildQuery(siteCode, probeName) {
    const filters = []
    if (siteCode) filters.push(`site_code="${siteCode}"`)
    if (probeName) filters.push(`name="${probeName}"`)

    const labelSelector = filters.length > 0 ? `{${filters.join(",")}}` : ""
    return `upright_http_response_status${labelSelector}`
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
    this.renderHeatmap(results)
    this.renderErrorList(results)
  }

  renderHeatmap(results) {
    if (results.length === 0) {
      this.heatmapTarget.innerHTML = this.noDataHtml()
      return
    }

    // Collect all timestamps
    const allTimestamps = new Set()
    results.forEach(result => {
      result.values.forEach(([timestamp]) => {
        allTimestamps.add(timestamp)
      })
    })

    const sortedTimestamps = Array.from(allTimestamps).sort((a, b) => a - b)
    const displayTimestamps = this.sampleTimestamps(sortedTimestamps, 20)

    // Build header row
    const headerCells = displayTimestamps.map(ts => {
      return `<th class="heatmap-time">${this.formatTimestamp(ts)}</th>`
    }).join("")

    // Build data rows
    const rows = results.map(result => {
      const name = result.metric.name || "Unknown"
      const valueMap = new Map(result.values.map(([ts, val]) => [ts, parseInt(val)]))

      const cells = displayTimestamps.map(ts => {
        const status = valueMap.get(ts)
        if (status === undefined) {
          return `<td class="heatmap-cell status-unknown">—</td>`
        }
        const colorClass = this.statusColorClass(status)
        return `<td class="heatmap-cell ${colorClass}">${status}</td>`
      }).join("")

      return `<tr><td class="heatmap-probe">${name}</td>${cells}</tr>`
    }).join("")

    this.heatmapTarget.innerHTML = `
      <div class="heatmap-wrapper">
        <table class="heatmap-table">
          <thead>
            <tr>
              <th class="heatmap-probe-header">Probe</th>
              ${headerCells}
            </tr>
          </thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    `
  }

  renderErrorList(results) {
    const errors = []

    results.forEach(result => {
      const name = result.metric.name || "Unknown"
      const target = result.metric.probe_target || ""

      result.values.forEach(([timestamp, value]) => {
        const status = parseInt(value)
        if (status >= 400) {
          errors.push({
            timestamp: timestamp,
            name: name,
            target: target,
            status: status
          })
        }
      })
    })

    // Sort by timestamp descending, take last 50
    errors.sort((a, b) => b.timestamp - a.timestamp)
    const recentErrors = errors.slice(0, 50)

    if (recentErrors.length === 0) {
      this.errorListTarget.innerHTML = `
        <div class="no-errors-message">
          No HTTP errors in the selected time range.
        </div>
      `
      return
    }

    const rows = recentErrors.map(error => {
      const colorClass = this.statusColorClass(error.status)
      const time = this.formatFullTimestamp(error.timestamp)

      return `
        <tr>
          <td class="error-time">${time}</td>
          <td class="error-probe">${error.name}</td>
          <td class="error-target">${this.truncateUrl(error.target)}</td>
          <td class="${colorClass}">${error.status}</td>
        </tr>
      `
    }).join("")

    this.errorListTarget.innerHTML = `
      <h3>Recent Errors</h3>
      <table class="error-table">
        <thead>
          <tr>
            <th>Time</th>
            <th>Probe</th>
            <th>Target</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>${rows}</tbody>
      </table>
    `
  }

  sampleTimestamps(timestamps, maxCount) {
    if (timestamps.length <= maxCount) return timestamps

    const step = Math.ceil(timestamps.length / maxCount)
    return timestamps.filter((_, index) => index % step === 0)
  }

  statusColorClass(status) {
    if (status >= 200 && status < 300) return "status-2xx"
    if (status >= 300 && status < 400) return "status-3xx"
    if (status >= 400 && status < 500) return "status-4xx"
    if (status >= 500) return "status-5xx"
    return "status-unknown"
  }

  formatTimestamp(timestamp) {
    const date = new Date(timestamp * 1000)
    const range = this.timeParams.range

    if (range.includes("d") && parseInt(range) > 1) {
      return date.toLocaleDateString([], { month: "short", day: "numeric" })
    }
    return date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
  }

  formatFullTimestamp(timestamp) {
    const date = new Date(timestamp * 1000)
    return date.toLocaleString([], {
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit"
    })
  }

  truncateUrl(url) {
    if (!url) return "—"
    if (url.length <= 50) return url
    return url.substring(0, 47) + "..."
  }

  noDataHtml() {
    return `
      <div class="no-data-message">
        No HTTP status data available for the selected filters and time range.
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
    this.heatmapTarget.innerHTML = `<div class="error-message">${message}</div>`
    this.errorListTarget.innerHTML = ""
  }
}

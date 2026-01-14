# Upright

Upright is a self-hosted synthetic monitoring system. It provides a framework for running health check probes from multiple geographic locations and reporting metrics via Prometheus. Alerts can then be configured with AlertManager.

## Features

- **Playwright Probes** - Browser-based probes for complex user flows
- **HTTP Probes** - Simple HTTP health checks with configurable expected status codes
- **SMTP Probes** - EHLO handshake verification for mail servers
- **Multi-Site Support** - Run probes from multiple geographic locations with staggered scheduling
- **Observability** - Built-in Prometheus metrics, OpenTelemetry tracing, and AlertManager support
- **Configurable Authentication** - OmniAuth integration with support for any OIDC provider

## Installation

### Quick Start (New Project)

Create a new Rails application and install Upright:

```bash
rails new my-upright --database=sqlite3 --skip-test
cd my-upright
bundle add upright --github=basecamp/upright
bin/rails generate upright:install
bin/rails db:migrate
```

Mount the engine in your routes:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount Upright::Engine => "/"
end
```

Start the server:

```bash
bin/rails server
```

Visit http://localhost:3000 to see your Upright instance.

### What the Generator Creates

The `upright:install` generator creates:

- `config/initializers/upright.rb` - Engine configuration
- `config/sites.yml` - Site/location definitions
- `config/probes/http_probes.yml` - HTTP probe definitions
- `config/probes/smtp_probes.yml` - SMTP probe definitions
- `config/prometheus/prometheus.yml` - Prometheus configuration
- `config/alertmanager/alertmanager.yml` - AlertManager configuration
- `config/otel_collector.yml` - OpenTelemetry Collector configuration

## Configuration

### Basic Setup

```ruby
# config/initializers/upright.rb
Upright.configure do |config|
  config.service_name = "my-upright"
  config.sites_config_path = Rails.root.join("config/sites.yml")

  # Probe settings
  config.default_timeout = 10
  config.user_agent = "Upright/1.0"

  # Storage paths
  config.prometheus_dir = Rails.root.join("tmp/prometheus")
  config.video_storage_dir = Rails.root.join("storage/videos")
  config.storage_state_dir = Rails.root.join("storage/auth_state")

  # Playwright (optional)
  config.playwright_server_url = ENV["PLAYWRIGHT_SERVER_URL"]

  # Observability endpoints
  config.otel_endpoint = ENV["OTEL_ENDPOINT"]
  config.prometheus_url = ENV["PROMETHEUS_URL"]
  config.alert_webhook_url = ENV["ALERT_WEBHOOK_URL"]
end
```

### Site Configuration

Define your monitoring locations in `config/sites.yml`:

```yaml
sites:
  - code: nyc
    city: New York City
    country: US
    geohash: dr5reg
    provider: digitalocean
    stagger_index: 0
    host: nyc.upright.example.com

  - code: ams
    city: Amsterdam
    country: NL
    geohash: u17982
    provider: digitalocean
    stagger_index: 1
    host: ams.upright.example.com

  - code: sfo
    city: San Francisco
    country: US
    geohash: 9q8yy
    provider: digitalocean
    stagger_index: 2
    host: sfo.upright.example.com
```

Each site node identifies itself via the `SITE_CODE` environment variable.

### Authentication

Upright supports OmniAuth for authentication. Configure your preferred provider:

**Option 1: OpenID Connect (Logto, Keycloak, etc.)**

```ruby
# Gemfile
gem "omniauth_openid_connect"

# config/initializers/upright.rb
Upright.configure do |config|
  config.auth_provider = :openid_connect
  config.auth_options = {
    issuer: "https://your-tenant.logto.app/oidc",
    client_id: ENV["OIDC_CLIENT_ID"],
    client_secret: ENV["OIDC_CLIENT_SECRET"]
  }
end
```

**Option 2: Simple Identity (no external provider)**

```ruby
# Gemfile
gem "omniauth-identity"

# config/initializers/upright.rb
Upright.configure do |config|
  config.auth_provider = :identity
  config.auth_options = { model: Upright::User }
end
```

**Option 3: Disable authentication**

```ruby
Upright.configure do |config|
  config.auth_provider = nil
end
```

## Defining Probes

### HTTP Probes

Add probes to `config/probes/http_probes.yml`:

```yaml
- name: Main Website
  url: https://example.com
  expected_status: 200

- name: API Health
  url: https://api.example.com/health
  expected_status: 200

- name: Admin Panel
  url: https://admin.example.com
  basic_auth_credentials: admin_auth  # Key in Rails credentials
```

### SMTP Probes

Add probes to `config/probes/smtp_probes.yml`:

```yaml
- name: Primary Mail Server
  host: mail.example.com

- name: Backup Mail Server
  host: mail2.example.com
```

### Playwright Probes

Generate a new browser-based probe:

```bash
bin/rails generate upright:playwright_probe MyServiceAuth
```

This creates a probe class:

```ruby
# app/models/probes/playwright/my_service_auth_probe.rb
class Probes::Playwright::MyServiceAuthProbe < Upright::Probes::Playwright::Base
  # Optionally authenticate before running
  # authenticate_with_form :my_service

  def check
    page.goto("https://app.example.com")
    page.fill('[name="email"]', "test@example.com")
    page.click('button[type="submit"]')
    page.wait_for_selector(".dashboard")
  end
end
```

#### Creating Authenticators

For probes that require authentication, create an authenticator:

```ruby
# app/models/playwright/authenticator/my_service.rb
class Playwright::Authenticator::MyService < Upright::Playwright::Authenticator::Base
  def authenticate
    page.goto("https://app.example.com/login")
    page.fill('[name="email"]', credentials[:email])
    page.fill('[name="password"]', credentials[:password])
    page.click('button[type="submit"]')
    page.wait_for_url("**/dashboard**")
  end

  private

  def credentials
    Rails.application.credentials.my_service
  end
end
```

## Scheduling

Configure probe scheduling with Solid Queue in `config/recurring.yml`:

```yaml
production:
  http_probes:
    class: Upright::ProbeCheckJob
    args: [http]
    schedule: every 30 seconds

  smtp_probes:
    class: Upright::ProbeCheckJob
    args: [smtp]
    schedule: every 30 seconds

  my_service_auth:
    class: Upright::ProbeCheckJob
    args: [playwright, MyServiceAuth]
    schedule: every 15 minutes
```

## System Requirements

### Minimum VM Specifications

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 2 vCPU | 2 vCPU |
| RAM | 2 GB | 4 GB |
| Disk | 25 GB | 50 GB |

Playwright browser automation is memory-intensive. For sites running many Playwright probes concurrently, consider 4 GB RAM.

### Software Requirements

- **OS**: Ubuntu 24.04+ or Debian 12+ (any Linux with Docker support)
- **Docker**: 24.0+ (installed automatically by Kamal)
- **Ruby**: 3.4+ (for local development only; production runs in Docker)
- **Rails**: 8.0+


### Firewall Rules

Open the following ports:

| Port | Protocol | Direction | Purpose |
|------|----------|-----------|---------|
| 22 | TCP | Inbound | SSH access |
| 80 | TCP | Inbound | HTTP (redirects to HTTPS) |
| 443 | TCP | Inbound | HTTPS |
| 25 | TCP | Outbound | SMTP probes (if used) |

### SMTP Port 25 Note

Most cloud providers block outbound port 25 by default to prevent spam. If you plan to use SMTP probes, you must request port 25 to be unblocked.

This is not required for HTTP or Playwright probes.

## DNS Setup

### Single Site

For a single monitoring node, create an A record pointing to your server:

```
upright.example.com    A    203.0.113.10
```

### Multi-Site

For multiple geographic locations, use subdomains for each site. Each subdomain points to a different server:

```
; Primary dashboard (optional - can point to any node)
app.upright.example.com      A    203.0.113.10

; Monitoring nodes
ams.upright.example.com      A    203.0.113.10    ; Amsterdam
nyc.upright.example.com      A    198.51.100.20   ; New York
sfo.upright.example.com      A    192.0.2.30      ; San Francisco
```

Alternatively, use a wildcard record if all sites share the same IP initially:

```
*.upright.example.com    A    203.0.113.10
```

### SSL Certificates

Kamal handles SSL automatically via kamal-proxy. For wildcard subdomains, you'll need a wildcard certificate. Configure in `config/deploy.yml`:

```yaml
proxy:
  ssl:
    certificate_pem: CERTIFICATE_PEM
    private_key_pem: PRIVATE_KEY_PEM
  hosts:
    - "*.upright.example.com"
```

## Deployment with Kamal

### Example `config/deploy.yml`

```yaml
service: upright
image: your-org/upright

servers:
  web:
    hosts:
      - nyc.upright.example.com
    env:
      tags:
        SITE_CODE: nyc

    hosts:
      - ams.upright.example.com
    env:
      tags:
        SITE_CODE: ams

    hosts:
      - sfo.upright.example.com
    env:
      tags:
        SITE_CODE: sfo

registry:
  server: ghcr.io
  username: your-org
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  clear:
    RAILS_ENV: production
    RAILS_LOG_TO_STDOUT: true
  secret:
    - RAILS_MASTER_KEY
    - OIDC_CLIENT_ID
    - OIDC_CLIENT_SECRET

accessories:
  playwright:
    image: mcr.microsoft.com/playwright:v1.55.0-noble
    cmd: npx -y playwright run-server --port 53333
    host: nyc.upright.example.com
    port: 53333
    env:
      clear:
        DEBUG: pw:api
```

### Single VM Setup

For a simple single-site deployment:

```yaml
service: upright
image: your-org/upright

servers:
  web:
    hosts:
      - monitoring.example.com
    env:
      tags:
        SITE_CODE: primary

env:
  clear:
    RAILS_ENV: production
    SITE_CODE: primary

accessories:
  playwright:
    image: mcr.microsoft.com/playwright:v1.55.0-noble
    cmd: npx -y playwright run-server --port 53333
    host: monitoring.example.com
    port: 53333
```

## Observability

### Prometheus

The engine exposes metrics at `/metrics`. Configure Prometheus to scrape:

```yaml
scrape_configs:
  - job_name: upright
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: /metrics
```

### Metrics Exposed

- `upright_probe_duration_seconds` - Probe execution duration
- `upright_probe_success` - Probe success/failure (1/0)
- `upright_probe_status_code` - HTTP status code for HTTP probes

Labels include: `probe_name`, `probe_type`, `site_code`, `site_city`, `site_country`

### AlertManager

Example alert rules (`prometheus/rules/upright.rules`):

```yaml
groups:
  - name: upright
    rules:
      - alert: ProbeDown
        expr: upright_probe_success == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Probe {{ $labels.probe_name }} is down"

      - alert: ProbeSlow
        expr: upright_probe_duration_seconds > 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Probe {{ $labels.probe_name }} is slow"
```

### OpenTelemetry

Traces are automatically created for each probe execution. Configure your collector endpoint:

```ruby
Upright.configure do |config|
  config.otel_endpoint = "https://otel.example.com:4318"
end
```

## Development

### Running Playwright Probes Locally

```bash
LOCAL_PLAYWRIGHT=1 bin/rails console
```

```ruby
Probes::Playwright::MyServiceAuthProbe.check
```

### Testing

```bash
bin/rails test
```

## License

The gem is available under the terms of the [O'Saasy License](LICENSE.md).

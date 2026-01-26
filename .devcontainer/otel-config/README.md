# OTEL Configuration for Local Development

This directory contains OpenTelemetry (OTEL) configuration files for local development observability stack.

## Files

### Tempo Configuration
- **tempo.yml** - Grafana Tempo configuration for receiving and storing traces via OTLP

### Grafana Provisioning
- **grafana-datasources.yml** - Auto-configures Tempo and Loki data sources in Grafana
- **grafana-dashboards.yml** - Dashboard provider configuration
- **dashboard-app-observability.json** - Pre-loaded dashboard showing recent traces and logs

## Usage

These configs are mounted into the docker-compose services for local development only.
They are not part of the production deployment.

### Access Points
- **Grafana UI**: http://localhost:3000 (no login required)
- **Tempo**: http://localhost:3200
- **Loki**: http://localhost:3100

### Pre-configured Features
- Tempo and Loki data sources are automatically configured
- "Application Observability" dashboard is pre-loaded
- Traces link to logs and vice versa
- Auto-refresh every 5 seconds

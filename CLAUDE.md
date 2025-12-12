# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
make up              # Start all services
make down            # Stop all services
make restart         # Restart all services
make status          # Check service health
make logs            # View all logs (follow mode)
make logs-collector  # View OTel collector logs
make clean           # Stop and remove volumes
make validate-config # Validate OTel collector config
```

## Architecture

Docker Compose stack for Claude Code observability:

```
Claude Code → OTel Collector (4317) → Prometheus (9090) → Grafana (8000)
                                    → Loki (3100)      ↗
```

- **OTel Collector** (`collector-config.yaml`): Receives OTLP telemetry, routes metrics to Prometheus and logs to Loki
- **Prometheus**: Time-series DB for metrics (cost, tokens, LOC, commits, PRs)
- **Loki**: Log aggregation for events (prompts, tool results, API requests)
- **Grafana**: Pre-provisioned dashboard at `grafana/dashboards/claude-code-dashboard.json`

## Key Files

- `collector-config.yaml` - OTel pipelines (receivers, processors, exporters)
- `grafana/provisioning/datasources/datasources.yml` - Auto-configured Prometheus + Loki sources
- `grafana/provisioning/dashboards/dashboards.yml` - Dashboard auto-discovery
- `.env.claude` - Environment variables template for Claude Code telemetry

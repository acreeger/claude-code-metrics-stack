.PHONY: up down restart logs logs-collector logs-prometheus logs-loki logs-grafana status clean validate-config setup-claude help

# Default target
help:
	@echo "Claude Code Metrics Stack - Available Commands"
	@echo ""
	@echo "Stack Management:"
	@echo "  make up              - Start all services"
	@echo "  make down            - Stop all services"
	@echo "  make restart         - Restart all services"
	@echo "  make clean           - Stop services and remove volumes"
	@echo "  make status          - Show status of all services"
	@echo ""
	@echo "Logs:"
	@echo "  make logs            - View logs from all services"
	@echo "  make logs-collector  - View OTel collector logs"
	@echo "  make logs-prometheus - View Prometheus logs"
	@echo "  make logs-loki       - View Loki logs"
	@echo "  make logs-grafana    - View Grafana logs"
	@echo ""
	@echo "Configuration:"
	@echo "  make validate-config - Validate configuration files"
	@echo "  make setup-claude    - Show Claude Code setup instructions"
	@echo ""
	@echo "URLs:"
	@echo "  Grafana:    http://localhost:8000 (admin/admin)"
	@echo "  Prometheus: http://localhost:9090"
	@echo "  Loki:       http://localhost:3100"

# Start all services
up:
	@echo "Starting Claude Code metrics stack..."
	docker compose up -d
	@echo ""
	@echo "Services started! Access points:"
	@echo "  Grafana:    http://localhost:8000 (admin/admin)"
	@echo "  Prometheus: http://localhost:9090"
	@echo ""
	@echo "Run 'make setup-claude' to see how to configure Claude Code"

# Stop all services
down:
	@echo "Stopping Claude Code metrics stack..."
	docker compose down

# Restart all services
restart: down up

# View all logs
logs:
	docker compose logs -f

# View specific service logs
logs-collector:
	docker compose logs -f otel-collector

logs-prometheus:
	docker compose logs -f prometheus

logs-loki:
	docker compose logs -f loki

logs-grafana:
	docker compose logs -f grafana

# Show status
status:
	@echo "Service Status:"
	@docker compose ps
	@echo ""
	@echo "Checking connectivity..."
	@curl -s -o /dev/null -w "Prometheus: %{http_code}\n" http://localhost:9090/-/healthy 2>/dev/null || echo "Prometheus: not reachable"
	@curl -s -o /dev/null -w "Loki: %{http_code}\n" http://localhost:3100/ready 2>/dev/null || echo "Loki: not reachable"
	@curl -s -o /dev/null -w "Grafana: %{http_code}\n" http://localhost:8000/api/health 2>/dev/null || echo "Grafana: not reachable"

# Clean up everything
clean:
	@echo "Stopping services and removing volumes..."
	docker compose down -v
	@echo "Cleaned up!"

# Validate configuration
validate-config:
	@echo "Validating configuration files..."
	@docker run --rm -v $(PWD)/collector-config.yaml:/etc/otel-collector-config.yaml:ro \
		otel/opentelemetry-collector-contrib:latest \
		validate --config=/etc/otel-collector-config.yaml && echo "OTel Collector config: OK" || echo "OTel Collector config: INVALID"
	@echo "Configuration validation complete"

# Show Claude Code setup instructions
setup-claude:
	@echo ""
	@echo "=============================================="
	@echo "  Claude Code Telemetry Setup Instructions"
	@echo "=============================================="
	@echo ""
	@echo "Add these environment variables before running Claude Code:"
	@echo ""
	@echo "  export CLAUDE_CODE_ENABLE_TELEMETRY=1"
	@echo "  export OTEL_METRICS_EXPORTER=otlp"
	@echo "  export OTEL_LOGS_EXPORTER=otlp"
	@echo "  export OTEL_EXPORTER_OTLP_PROTOCOL=grpc"
	@echo "  export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317"
	@echo ""
	@echo "For debugging (faster export intervals):"
	@echo ""
	@echo "  export OTEL_METRIC_EXPORT_INTERVAL=10000"
	@echo "  export OTEL_LOGS_EXPORT_INTERVAL=5000"
	@echo ""
	@echo "Optional - Enable prompt logging (privacy consideration):"
	@echo ""
	@echo "  export OTEL_LOG_USER_PROMPTS=1"
	@echo ""
	@echo "Or add to your shell profile (~/.zshrc or ~/.bashrc):"
	@echo ""
	@cat .env.claude
	@echo ""
	@echo "Then run: claude"
	@echo ""

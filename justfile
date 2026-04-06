set dotenv-load := true

_init:
    -touch .env


# Build the development container image
build: _init
    docker compose build svc-agent-workflows

# Bring up the CI profile and wait for healthchecks to pass
ci_up: _init
    docker compose -f docker-compose.yaml --profile ci up --wait --remove-orphans
    @echo "Creating databases..."
    docker compose exec -T svc-pg-control-plane curl -s http://localhost:6666/create_database/development || true
    docker compose exec -T svc-pg-control-plane curl -s http://localhost:6666/create_database/test || true
    docker compose exec -T svc-pg-control-plane curl -s http://localhost:6666/create_database/translations || true
    docker compose exec -T svc-pg-control-plane curl -s http://localhost:6666/create_database/ai_workflows || true
    @echo "Running migrations..."
    docker compose exec -T svc-data-gateway python -m migrations.run_alembic_migration

# Execute tests inside the container
test *ARGS: _init
    docker compose exec -T -e OPENAI_API_KEY="${OPENAI_API_KEY:-dummy-key}" -e PYTHONPATH=.:local_modules/agentic-ai-testbed svc-agent-workflows pytest {{ ARGS }}

# Build and test the container (slow loop)
build_test *ARGS:
    just build
    just ci_up
    just test {{ ARGS }}
    docker compose down

# Start the development environment
up: _init
    docker compose up -d

# Stop the development environment
down: _init
    docker compose down

# View logs
logs: _init
    docker compose logs -f

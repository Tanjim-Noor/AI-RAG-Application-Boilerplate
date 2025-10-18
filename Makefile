.PHONY: help setup dev test lint format clean reset-db

help: ## Display available commands
	@echo "Available commands:"
	@echo "  make setup     - Run initial setup"
	@echo "  make dev       - Start development servers"
	@echo "  make test      - Run tests"
	@echo "  make lint      - Run linters"
	@echo "  make format    - Format code"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make reset-db  - Reset database"

setup: ## Run initial setup
	@powershell -ExecutionPolicy Bypass -File ./scripts/setup.ps1

dev: ## Start development servers
	@cd docker && docker-compose up -d && cd .. && pnpm dev

test: ## Run tests
	@pnpm test

lint: ## Run linters
	@pnpm lint

format: ## Format code
	@pnpm format

clean: ## Clean build artifacts and volumes
	@pnpm clean
	@cd docker && docker-compose down -v

reset-db: ## Reset database
	@powershell -ExecutionPolicy Bypass -File ./scripts/reset-db.ps1

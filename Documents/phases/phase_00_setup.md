# Phase 0: Project Setup

## Objective
Create the complete monorepo structure using Turborepo and pnpm workspaces. This phase establishes the foundation for both frontend and backend applications with proper configuration files, development scripts, and Docker setup for PostgreSQL.

## Context
You are building a fullstack AI RAG application boilerplate. The project will have a React frontend and FastAPI backend, managed as a monorepo. Only the database will run in Docker; the applications will run natively for fast development iteration.

## Requirements

### Tech Stack
- **Monorepo Management**: Turborepo with pnpm workspaces
- **Frontend**: React + TypeScript + Vite
- **Backend**: Python + FastAPI
- **Database**: PostgreSQL (Docker)
- **Package Manager**: pnpm
- **Development**: Hot reload for both frontend and backend

### Directory Structure to Create

```
ai-boilerplate/
├── apps/
│   ├── frontend/
│   │   ├── src/
│   │   ├── public/
│   │   ├── index.html
│   │   ├── package.json
│   │   ├── vite.config.ts
│   │   ├── tsconfig.json
│   │   ├── tailwind.config.js
│   │   ├── postcss.config.js
│   │   └── .eslintrc.cjs
│   │
│   └── backend/
│       ├── app/
│       │   └── main.py (basic FastAPI app)
│       ├── tests/
│       ├── alembic/
│       ├── package.json (for Turborepo integration)
│       ├── requirements.txt
│       ├── pyproject.toml
│       └── .python-version
│
├── packages/
│   └── (empty for now, reserved for shared code)
│
├── docker/
│   └── docker-compose.yml
│
├── scripts/
│   ├── setup.sh
│   └── reset-db.sh
│
├── .github/
│   └── workflows/
│       └── (empty for now)
│
├── package.json (root)
├── pnpm-workspace.yaml
├── turbo.json
├── .env.example
├── .gitignore
├── .prettierrc
├── .prettierignore
├── Makefile
└── README.md
```

## Tasks

### 1. Root Configuration Files

#### package.json (root)
Create a root package.json that:
- Defines the monorepo workspace
- Includes Turborepo as a dev dependency
- Has scripts for `dev`, `build`, `test`, `lint`, `format`, `clean`
- Specifies package manager as pnpm
- Sets engine requirements (Node >= 18, pnpm >= 8)
- Uses latest versions of all dependencies

#### pnpm-workspace.yaml
Configure pnpm workspaces to include:
- All apps under `apps/*`
- All packages under `packages/*`

#### turbo.json
Set up Turborepo pipeline with:
- `dev` task (cache: false, persistent: true)
- `build` task (with dependency ordering)
- `test` task
- `lint` task
- `format` task
- `clean` task
- Global dependencies on `.env` file

#### .env.example
Create template environment file with:
- Database connection URL for PostgreSQL
- JWT secret key placeholder
- Algorithm for JWT
- Token expiration time
- LLM provider configuration (default provider, API keys for OpenAI and Anthropic)
- Embedding model configuration
- ChromaDB persistence directory
- File upload directory and size limits
- Frontend API base URL

### 2. Frontend Scaffold (apps/frontend)

#### package.json
Configure with:
- Name: "frontend"
- Private: true
- Scripts: `dev`, `build`, `preview`, `test`, `lint`, `format`, `clean`
- Dependencies: React, React DOM, React Router, Redux Toolkit, React-Redux, react-markdown (all latest)
- Dev dependencies: Vite, TypeScript, Vitest, ESLint, Prettier, Tailwind CSS, PostCSS, Autoprefixer, React types

#### vite.config.ts
Set up Vite with:
- React plugin
- Port 5173
- Proxy API requests to backend (http://localhost:8000)
- Open browser on start
- Source maps in development

#### tsconfig.json
Configure TypeScript with:
- Strict mode enabled
- Path aliases (`@/` pointing to `./src/`)
- JSX support
- Module resolution bundler
- ES2020 target

#### tailwind.config.js
Configure Tailwind to:
- Scan all tsx/ts files in src
- Include default theme
- Set up dark mode (class strategy)

#### postcss.config.js
Include Tailwind and Autoprefixer plugins

#### .eslintrc.cjs
Set up ESLint with:
- React plugin
- TypeScript parser
- Recommended rules
- Import order rules

#### index.html
Create minimal HTML template with:
- Root div
- Script tag for main.tsx
- Title: "AI RAG Boilerplate"

#### src/ folder structure
Create empty folders:
- `src/app/` (app configuration)
- `src/features/` (feature modules)
- `src/shared/` (shared code)
- `src/assets/` (static assets)

Create placeholder files:
- `src/main.tsx` (React entry point with basic app render)
- `src/App.tsx` (minimal app component with "Hello World")
- `src/index.css` (Tailwind imports)

### 3. Backend Scaffold (apps/backend)

#### package.json
Create minimal package.json for Turborepo with:
- Name: "backend"
- Private: true
- Scripts that wrap Python commands:
  - `dev`: activate venv and run uvicorn with reload
  - `test`: activate venv and run pytest
  - `lint`: activate venv and run ruff check
  - `format`: activate venv and run ruff format
  - `migrate`: activate venv and run alembic upgrade head
  - `clean`: remove cache directories

#### requirements.txt
List all required Python packages (use latest compatible versions):
- fastapi
- uvicorn[standard]
- sqlmodel
- psycopg2-binary
- alembic
- pydantic-settings
- python-jose[cryptography]
- passlib[bcrypt]
- python-multipart
- chromadb
- langchain
- langchain-openai
- langchain-anthropic
- pypdf
- python-docx
- pytest
- pytest-asyncio
- httpx
- ruff

#### pyproject.toml
Configure project metadata and Ruff settings:
- Line length 100
- Python version 3.10+
- Exclude patterns (venv, migrations, __pycache__)

#### .python-version
Specify Python 3.10 or higher

#### app/main.py
Create minimal FastAPI application with:
- App instance creation
- CORS middleware (allow localhost:5173)
- Root endpoint returning {"message": "AI RAG Boilerplate API"}
- Health check endpoint at `/health`

#### alembic/ folder
Create placeholder for migrations (will configure in next phase)

#### tests/ folder
Create empty tests directory with `__init__.py`

### 4. Docker Configuration

#### docker-compose.yml
Set up PostgreSQL service with:
- Latest postgres image
- Environment variables (POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB)
- Port mapping 5432:5432
- Named volume for data persistence
- Health check using pg_isready
- Health check interval of 5 seconds

Define named volume `postgres_data`

### 5. Development Scripts

#### scripts/setup.sh
Create bash script that:
- Checks for required tools (docker, pnpm, python3)
- Copies .env.example to .env if not exists
- Runs pnpm install at root
- Creates Python virtual environment in apps/backend
- Activates venv and installs requirements
- Starts PostgreSQL via docker-compose
- Waits for database health check
- Prints success message with next steps

Make script executable (chmod +x)

#### scripts/reset-db.sh
Create bash script that:
- Prompts for confirmation
- Stops and removes database container and volume
- Restarts PostgreSQL
- Waits for health check
- Runs migrations (placeholder for now)
- Prints completion message

Make script executable (chmod +x)

### 6. Makefile
Create Makefile with targets:
- `help`: Display available commands
- `setup`: Run setup.sh script
- `dev`: Start docker-compose and run pnpm dev
- `test`: Run pnpm test
- `lint`: Run pnpm lint
- `format`: Run pnpm format
- `clean`: Clean all build artifacts and volumes
- `reset-db`: Run reset-db.sh script

Set `.PHONY` for all targets

### 7. Configuration Files

#### .gitignore
Ignore:
- node_modules
- dist, build directories
- .env (but not .env.example)
- Python cache (__pycache__, *.pyc)
- Python virtual environment (venv, .venv)
- IDE files (.vscode, .idea)
- OS files (.DS_Store)
- Turborepo cache (.turbo)
- Test coverage
- Database data directory
- Upload directories
- ChromaDB storage

#### .prettierrc
Configure Prettier with:
- Semi: true
- Single quote: true
- Tab width: 2
- Trailing comma: es5
- Print width: 100

#### .prettierignore
Ignore:
- node_modules
- dist, build
- coverage
- .turbo
- pnpm-lock.yaml

### 8. README.md
Create comprehensive README with sections:

**Title and Description**
- Project name: "AI RAG Boilerplate"
- Brief description of what it is
- Key features list

**Prerequisites**
- Node.js version
- Python version
- pnpm installation
- Docker installation

**Quick Start**
- Clone repository
- Copy .env.example to .env
- Update API keys in .env
- Run `make setup` or `pnpm install && ./scripts/setup.sh`
- Run `make dev` or `pnpm dev`
- Access URLs (frontend, backend, API docs)

**Project Structure**
- Brief explanation of monorepo layout
- Purpose of apps/ and packages/

**Development**
- Available make commands
- How to run tests
- How to lint/format
- How to reset database

**Tech Stack**
- List all major technologies

**Next Steps**
- Links to implementation phases
- Contribution guidelines reference

## Validation Checklist

After completing this phase, verify:

- [ ] `pnpm install` completes successfully at root
- [ ] Frontend dependencies install correctly
- [ ] Backend virtual environment creates and requirements install
- [ ] `docker-compose up -d` starts PostgreSQL
- [ ] Database health check passes
- [ ] `pnpm dev` starts both frontend and backend
- [ ] Frontend accessible at http://localhost:5173
- [ ] Backend accessible at http://localhost:8000
- [ ] API docs visible at http://localhost:8000/docs
- [ ] Root endpoint returns expected message
- [ ] Hot reload works (change App.tsx, change main.py)
- [ ] `make test` runs (even if no tests yet)
- [ ] `make lint` runs
- [ ] All scripts are executable
- [ ] .env created from .env.example
- [ ] .gitignore prevents committing sensitive files

## Expected Output

When complete, running `make dev` should:
1. Start PostgreSQL in Docker
2. Start FastAPI backend on port 8000 with auto-reload
3. Start Vite frontend on port 5173 with HMR
4. Display logs from all services in terminal

Opening http://localhost:5173 should show a basic React app saying "Hello World"

Opening http://localhost:8000/docs should show FastAPI Swagger documentation

## Common Issues to Address

- Ensure Python venv activation works in package.json scripts
- Handle different shells (bash vs zsh) in scripts
- Verify port 5173 and 8000 are available
- Check Docker daemon is running
- Confirm pnpm is installed globally
- Validate .env file is copied and not ignored by git

## Notes for AI Assistant

- Use latest stable versions of all packages
- Ensure cross-platform compatibility (macOS, Linux, Windows WSL)
- Follow best practices for each technology
- Keep configurations minimal but complete
- Add comments in config files explaining key settings
- Ensure scripts have proper error handling
- Make all file paths relative to project root
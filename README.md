# AI RAG Boilerplate

A modern, production-ready fullstack boilerplate for building AI-powered applications with RAG (Retrieval-Augmented Generation) capabilities.

## 🚀 Features

- **Monorepo Architecture** - Managed with Turborepo and pnpm workspaces
- **Modern Frontend** - React 18 + TypeScript + Vite + Tailwind CSS
- **Powerful Backend** - FastAPI + Python with async support
- **Vector Database** - ChromaDB for semantic search and embeddings
- **LLM Integration** - Support for OpenAI and Anthropic models
- **Type Safety** - Full TypeScript and Python type hints
- **Hot Reload** - Fast development with HMR for both frontend and backend
- **Docker Support** - PostgreSQL database in Docker
- **Code Quality** - ESLint, Prettier, Ruff for consistent code formatting

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** >= 18.0.0
- **Python** >= 3.10
- **pnpm** >= 8.0.0 (install with `npm install -g pnpm`)
- **Docker** and Docker Compose (for PostgreSQL)

## 🏁 Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd NotebookLM_simplified
   ```

2. **Copy environment variables**
   ```bash
   cp .env.example .env
   ```

3. **Update API keys in `.env`**
   - Add your OpenAI API key
   - Add your Anthropic API key (optional)
   - Update other configuration as needed

4. **Run setup**
   ```bash
   make setup
   # OR
   powershell -ExecutionPolicy Bypass -File ./scripts/setup.ps1
   ```

5. **Start development servers**
   
   **Windows (PowerShell):**
   ```powershell
   .\scripts\dev.ps1 dev
   # OR
   pnpm dev
   ```
   
   **Mac/Linux (if make is installed):**
   ```bash
   make dev
   # OR
   pnpm dev
   ```

6. **Access the applications**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

## 📁 Project Structure

```
./ (Root)
├── apps/
│   ├── frontend/          # React + TypeScript + Vite
│   │   ├── src/
│   │   │   ├── app/       # App configuration
│   │   │   ├── features/  # Feature modules
│   │   │   ├── shared/    # Shared utilities
│   │   │   └── assets/    # Static assets
│   │   └── package.json
│   │
│   └── backend/           # FastAPI + Python
│       ├── app/           # Application code
│       ├── tests/         # Test files
│       ├── alembic/       # Database migrations
│       └── requirements.txt
│
├── packages/              # Shared packages (future)
├── docker/                # Docker configurations
├── scripts/               # Setup and utility scripts
├── .github/               # GitHub workflows and configurations
├── venv/                  # Root Python virtual environment
└── turbo.json            # Turborepo configuration
```

## 🛠️ Development

### Available Commands

**Windows (PowerShell):**
```powershell
.\scripts\dev.ps1 <command>
```

**Mac/Linux (if make is installed):**
```bash
make <command>
```

**Or use pnpm directly:**
```bash
pnpm <command>
```

| Command | Description |
|---------|-------------|
| `setup` | Run initial project setup |
| `dev` | Start all development servers |
| `test` | Run all tests |
| `lint` | Run linters on all code |
| `format` | Format all code |
| `clean` | Clean build artifacts and volumes |
| `reset-db` | Reset database (deletes all data) |

**Examples:**
```powershell
# Windows
.\scripts\dev.ps1 setup
.\scripts\dev.ps1 dev
.\scripts\dev.ps1 test

# Or use pnpm
pnpm dev
pnpm test
```

### Frontend Development

```bash
cd apps/frontend
pnpm dev      # Start dev server
pnpm build    # Build for production
pnpm test     # Run tests
pnpm lint     # Run ESLint
```

### Backend Development

```bash
cd apps/backend
pnpm dev      # Start FastAPI with hot reload
pnpm test     # Run pytest
pnpm lint     # Run ruff check
pnpm format   # Run ruff format
```

### Database Management

```bash
# Start database
cd docker && docker-compose up -d

# Stop database
cd docker && docker-compose down

# Reset database (WARNING: deletes all data)
make reset-db
```

## 🏗️ Tech Stack

### Frontend
- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Utility-first CSS framework
- **React Router** - Client-side routing
- **Redux Toolkit** - State management
- **Vitest** - Unit testing

### Backend
- **FastAPI** - Modern Python web framework
- **SQLModel** - SQL databases with Python type hints
- **Alembic** - Database migrations
- **Pydantic** - Data validation
- **ChromaDB** - Vector database for embeddings
- **LangChain** - LLM orchestration framework
- **pytest** - Testing framework
- **Ruff** - Fast Python linter and formatter

### Infrastructure
- **PostgreSQL** - Primary database
- **Docker** - Container orchestration
- **Turborepo** - Monorepo build system
- **pnpm** - Fast, disk space efficient package manager

## 🔐 Environment Variables

The `.env.example` file contains all required environment variables. Copy it to `.env` and update the values:

```env
# Database
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/ai_boilerplate

# JWT
JWT_SECRET_KEY=your-secret-key-here-change-in-production
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

# LLM Providers
DEFAULT_LLM_PROVIDER=openai
OPENAI_API_KEY=your-openai-api-key-here
ANTHROPIC_API_KEY=your-anthropic-api-key-here

# Embeddings
EMBEDDING_MODEL=text-embedding-3-small

# Storage
CHROMADB_PERSIST_DIRECTORY=./chromadb_data
UPLOAD_DIR=./uploads
MAX_FILE_SIZE_MB=10

# Frontend
VITE_API_BASE_URL=http://localhost:8000
```

## 📝 Package Version Management

This project follows a **dynamic package management** approach:

- **No hardcoded versions** in package.json files
- All packages use `"latest"` or are installed dynamically
- This ensures you always get the most recent stable versions
- Version resolution happens at install time via pnpm/pip

To install packages:
```bash
# Frontend
cd apps/frontend
pnpm add <package-name>

# Backend
cd apps/backend
source venv/Scripts/activate  # Windows
pip install <package-name>
pip freeze > requirements.txt
```

## 🧪 Testing

```bash
# Run all tests
make test

# Frontend tests only
cd apps/frontend && pnpm test

# Backend tests only
cd apps/backend && pnpm test
```

## 🎨 Code Formatting

```bash
# Format all code
make format

# Frontend formatting
cd apps/frontend && pnpm format

# Backend formatting
cd apps/backend && pnpm format
```

## 🐛 Troubleshooting

### Port Already in Use

If ports 5173 or 8000 are already in use:
```bash
# Find process using port
netstat -ano | findstr :5173
netstat -ano | findstr :8000

# Kill process by PID
taskkill /PID <pid> /F
```

### Docker Issues

```bash
# Restart Docker Desktop
# Then restart the database
cd docker && docker-compose restart
```

### Python Virtual Environment

```bash
# Recreate virtual environment
cd apps/backend
Remove-Item -Recurse -Force venv
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## 📚 Next Steps

1. **Phase 1**: Implement backend authentication and database models
2. **Phase 2**: Build frontend UI components and routing
3. **Phase 8**: Integrate RAG capabilities with ChromaDB and LangChain

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## 📄 License

MIT License - feel free to use this boilerplate for your projects!

## 🙏 Acknowledgments

Built with modern web technologies and AI capabilities to accelerate development of intelligent applications.

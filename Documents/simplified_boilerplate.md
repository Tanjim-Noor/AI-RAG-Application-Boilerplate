# Simplified Fullstack AI Boilerplate

## 1. Goal
A minimal, well-structured starting point for building RAG-based AI applications with clear separation between frontend and backend, focusing on rapid prototyping with room to grow.

## 2. Core Principles
- **Separation of Concerns**: Frontend and backend are completely independent modules
- **Simplicity First**: Start with essentials, add complexity only when needed
- **Model Agnostic**: Support multiple LLM providers through a unified interface
- **Clean Architecture**: Follow best practices for maintainable, scalable code
- **Local-First Development**: Everything runs locally with minimal dependencies

---

## 3. Essential Features (MVP)
- ✅ User authentication (register/login with JWT)
- ✅ Project/Notebook management (CRUD)
- ✅ Document upload and parsing (PDF, TXT, DOCX)
- ✅ Text chunking and embedding
- ✅ Vector storage and retrieval (using Chroma for simplicity)
- ✅ RAG query pipeline (retrieve + generate)
- ✅ Chat interface with streaming responses
- ✅ Conversation history

**Deferred to later:**
- Background workers (process synchronously for now)
- Advanced monitoring/observability
- Multi-tenancy and complex permissions
- Export features
- Production deployment configs

---

## 4. Tech Stack

### Frontend
- **React 18** + **TypeScript** - Type-safe component development
- **Vite** - Fast dev server and build tool
- **React Router** - Client-side routing
- **TanStack Query** - Server state management and caching
- **Tailwind CSS** - Utility-first styling
- **Axios** - HTTP client with interceptors
- **react-markdown** - Markdown rendering

### Backend
- **FastAPI** - Modern Python web framework with auto docs
- **Pydantic** - Data validation and settings
- **SQLModel** - SQL databases with Python type annotations
- **PostgreSQL** - Primary database
- **ChromaDB** - Vector database (embedded mode for simplicity)
- **LangChain** - LLM abstraction and RAG patterns
- **python-multipart** - File upload handling
- **pypdf** / **python-docx** - Document parsing
- **python-jose[cryptography]** - JWT tokens
- **passlib[bcrypt]** - Password hashing

### Development Tools
- **pnpm** - Fast package manager
- **Docker + Docker Compose** - Containerization for local dev
- **ESLint + Prettier** - Frontend code quality
- **Ruff** - Fast Python linter
- **pytest** - Backend testing
- **Vitest** - Frontend testing

---

## 5. Project Structure

```
ai-boilerplate/
├── frontend/                    # React application
│   ├── src/
│   │   ├── app/                # App-level configuration
│   │   │   ├── App.tsx
│   │   │   ├── router.tsx
│   │   │   └── providers.tsx
│   │   ├── features/           # Feature-based modules
│   │   │   ├── auth/
│   │   │   │   ├── components/
│   │   │   │   ├── hooks/
│   │   │   │   ├── api/
│   │   │   │   └── types.ts
│   │   │   ├── projects/
│   │   │   │   ├── components/
│   │   │   │   ├── hooks/
│   │   │   │   ├── api/
│   │   │   │   └── types.ts
│   │   │   ├── documents/
│   │   │   └── chat/
│   │   ├── shared/             # Shared utilities
│   │   │   ├── components/     # Reusable UI components
│   │   │   ├── hooks/          # Common hooks
│   │   │   ├── lib/            # Utilities and helpers
│   │   │   └── types/          # Shared types
│   │   ├── assets/             # Static assets
│   │   └── styles/             # Global styles
│   ├── public/
│   ├── index.html
│   ├── package.json
│   ├── vite.config.ts
│   ├── tsconfig.json
│   └── tailwind.config.js
│
├── backend/                     # FastAPI application
│   ├── app/
│   │   ├── main.py             # Application entry point
│   │   ├── config.py           # Settings and configuration
│   │   ├── database.py         # Database connection
│   │   ├── api/                # API routes
│   │   │   ├── deps.py         # Dependencies (auth, db session)
│   │   │   └── v1/
│   │   │       ├── __init__.py
│   │   │       ├── auth.py
│   │   │       ├── projects.py
│   │   │       ├── documents.py
│   │   │       └── chat.py
│   │   ├── core/               # Core business logic
│   │   │   ├── security.py     # Auth utilities
│   │   │   ├── llm/            # LLM integrations
│   │   │   │   ├── base.py     # Abstract provider
│   │   │   │   ├── openai.py
│   │   │   │   ├── anthropic.py
│   │   │   │   └── factory.py  # Provider factory
│   │   │   ├── embeddings/     # Embedding models
│   │   │   │   ├── base.py
│   │   │   │   └── openai.py
│   │   │   ├── rag/            # RAG pipeline
│   │   │   │   ├── chunker.py
│   │   │   │   ├── retriever.py
│   │   │   │   └── pipeline.py
│   │   │   └── parsers/        # Document parsers
│   │   │       ├── base.py
│   │   │       ├── pdf.py
│   │   │       └── docx.py
│   │   ├── models/             # SQLModel schemas
│   │   │   ├── user.py
│   │   │   ├── project.py
│   │   │   ├── document.py
│   │   │   └── message.py
│   │   ├── schemas/            # Pydantic schemas (API contracts)
│   │   │   ├── auth.py
│   │   │   ├── project.py
│   │   │   ├── document.py
│   │   │   └── chat.py
│   │   └── services/           # Business logic layer
│   │       ├── auth_service.py
│   │       ├── project_service.py
│   │       ├── document_service.py
│   │       └── chat_service.py
│   ├── tests/
│   ├── alembic/                # Database migrations
│   ├── requirements.txt
│   └── pyproject.toml
│
├── docker/
│   ├── Dockerfile.frontend
│   ├── Dockerfile.backend
│   └── docker-compose.yml
│
├── scripts/
│   ├── setup.sh               # Initial setup script
│   ├── dev.sh                 # Start dev environment
│   └── reset-db.sh            # Reset database
│
├── .env.example
├── .gitignore
├── README.md
└── Makefile                   # Common commands
```

---

## 6. Backend Architecture Details

### Layer Responsibilities

#### API Layer (`api/`)
- HTTP request/response handling
- Request validation (via Pydantic schemas)
- Route definitions
- Dependency injection (auth, db sessions)
- **No business logic**

#### Service Layer (`services/`)
- Orchestrates business operations
- Calls core utilities and repositories
- Transaction management
- Error handling and logging
- Returns data transfer objects (schemas)

#### Core Layer (`core/`)
- Domain logic and algorithms
- RAG pipeline components
- LLM provider abstractions
- Document parsing
- Embedding generation
- **Framework-agnostic** (can be reused in CLI tools, workers, etc.)

#### Models Layer (`models/`)
- SQLModel database models
- Represents database tables
- Relationships between entities

#### Schemas Layer (`schemas/`)
- Pydantic models for API contracts
- Request/response validation
- Separate from database models for flexibility

### Model-Agnostic LLM Design

```python
# core/llm/base.py
from abc import ABC, abstractmethod
from typing import AsyncIterator

class LLMProvider(ABC):
    @abstractmethod
    async def generate(self, prompt: str, **kwargs) -> str:
        pass
    
    @abstractmethod
    async def stream(self, prompt: str, **kwargs) -> AsyncIterator[str]:
        pass

# core/llm/factory.py
def get_llm_provider(provider: str, **config) -> LLMProvider:
    if provider == "openai":
        return OpenAIProvider(**config)
    elif provider == "anthropic":
        return AnthropicProvider(**config)
    # Add more providers as needed
```

---

## 7. Frontend Architecture Details

### Feature-Based Structure
Each feature is self-contained with its own:
- **components/**: UI components specific to the feature
- **hooks/**: Custom React hooks for state and logic
- **api/**: API client functions for backend communication
- **types.ts**: TypeScript interfaces and types

### Shared Module
Reusable code across features:
- **components/**: Generic UI components (Button, Input, Modal, etc.)
- **hooks/**: Common hooks (useAuth, useDebounce, etc.)
- **lib/**: Utility functions and helpers
- **types/**: Shared TypeScript types

### Example Feature Structure
```
features/chat/
├── components/
│   ├── ChatInterface.tsx
│   ├── MessageList.tsx
│   ├── MessageInput.tsx
│   └── SourceCitation.tsx
├── hooks/
│   ├── useChat.ts
│   └── useStreamingResponse.ts
├── api/
│   └── chatApi.ts
└── types.ts
```

---

## 8. API Design

### REST Endpoints

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh

GET    /api/v1/projects
POST   /api/v1/projects
GET    /api/v1/projects/{id}
PUT    /api/v1/projects/{id}
DELETE /api/v1/projects/{id}

POST   /api/v1/projects/{id}/documents      # Upload document
GET    /api/v1/projects/{id}/documents
DELETE /api/v1/documents/{id}

POST   /api/v1/projects/{id}/chat           # Send message
GET    /api/v1/projects/{id}/messages       # Get history
GET    /api/v1/projects/{id}/chat/stream    # SSE streaming endpoint
```

### Request/Response Examples

```json
// POST /api/v1/projects/{id}/chat
{
  "message": "What does the document say about X?",
  "stream": false
}

// Response
{
  "id": "msg_123",
  "content": "Based on the documents...",
  "sources": [
    {
      "document_id": "doc_456",
      "chunk_text": "Relevant excerpt...",
      "score": 0.89
    }
  ],
  "created_at": "2025-10-18T10:30:00Z"
}
```

---

## 9. Database Schema (Core Tables)

```sql
-- Users
users (
  id: UUID PRIMARY KEY,
  email: VARCHAR UNIQUE NOT NULL,
  hashed_password: VARCHAR NOT NULL,
  created_at: TIMESTAMP,
  updated_at: TIMESTAMP
)

-- Projects/Notebooks
projects (
  id: UUID PRIMARY KEY,
  user_id: UUID REFERENCES users(id),
  name: VARCHAR NOT NULL,
  description: TEXT,
  created_at: TIMESTAMP,
  updated_at: TIMESTAMP
)

-- Documents
documents (
  id: UUID PRIMARY KEY,
  project_id: UUID REFERENCES projects(id),
  filename: VARCHAR NOT NULL,
  file_path: VARCHAR NOT NULL,
  file_type: VARCHAR,
  status: VARCHAR,  -- 'processing', 'completed', 'failed'
  created_at: TIMESTAMP
)

-- Messages (Chat History)
messages (
  id: UUID PRIMARY KEY,
  project_id: UUID REFERENCES projects(id),
  role: VARCHAR,  -- 'user', 'assistant'
  content: TEXT NOT NULL,
  sources: JSONB,  -- Store citation info
  created_at: TIMESTAMP
)
```

**Note**: Vector embeddings are stored in ChromaDB with document/chunk references.

---

## 10. Development Workflow

### Initial Setup
```bash
# Clone and setup
git clone <repo>
cd ai-boilerplate
cp .env.example .env

# Edit .env with your API keys and config

# Run setup script
make setup
# or
./scripts/setup.sh
```

### Daily Development
```bash
# Start everything (postgres, frontend, backend)
make dev
# or
./scripts/dev.sh

# Frontend runs on: http://localhost:5173
# Backend runs on: http://localhost:8000
# API docs: http://localhost:8000/docs
```

### Testing
```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
pnpm test
```

---

## 11. Environment Configuration

### `.env.example`
```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/ai_boilerplate

# JWT
SECRET_KEY=your-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# LLM Provider (model-agnostic)
DEFAULT_LLM_PROVIDER=openai  # or anthropic, ollama, etc.
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# Embeddings
EMBEDDING_MODEL=text-embedding-3-small
EMBEDDING_PROVIDER=openai

# Vector Store
CHROMA_PERSIST_DIRECTORY=./data/chroma

# File Storage
UPLOAD_DIR=./data/uploads
MAX_UPLOAD_SIZE_MB=10

# Frontend
VITE_API_BASE_URL=http://localhost:8000
```

---

## 12. Key Implementation Notes

### RAG Pipeline Flow
1. **Document Upload** → Parse → Chunk → Store metadata in Postgres
2. **Embedding** → Generate embeddings → Store in ChromaDB with chunk reference
3. **Query** → Embed question → Retrieve top-k chunks → Build prompt → Generate response
4. **Response** → Stream to frontend → Save to message history

### Streaming Implementation
- Backend uses FastAPI's `StreamingResponse` with SSE
- Frontend uses EventSource or fetch with streaming
- Each chunk includes metadata for real-time citation display

### Authentication Flow
- User registers/logs in → receives JWT
- Frontend stores token in memory (or httpOnly cookie)
- All API requests include token in Authorization header
- Backend validates token via dependency injection

---

## 13. Docker Compose Setup

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: ai_boilerplate
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  backend:
    build:
      context: ./backend
      dockerfile: ../docker/Dockerfile.backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:password@postgres:5432/ai_boilerplate
    depends_on:
      - postgres
    volumes:
      - ./backend:/app
      - ./data:/data

  frontend:
    build:
      context: ./frontend
      dockerfile: ../docker/Dockerfile.frontend
    ports:
      - "5173:5173"
    volumes:
      - ./frontend:/app
      - /app/node_modules

volumes:
  postgres_data:
```

---

## 14. Makefile Commands

```makefile
.PHONY: setup dev test clean

setup:
	@echo "Setting up development environment..."
	cd frontend && pnpm install
	cd backend && pip install -r requirements.txt
	cd backend && alembic upgrade head

dev:
	docker-compose up

test:
	cd backend && pytest
	cd frontend && pnpm test

clean:
	docker-compose down -v
	rm -rf frontend/node_modules
	rm -rf backend/.venv

lint:
	cd backend && ruff check .
	cd frontend && pnpm lint

format:
	cd backend && ruff format .
	cd frontend && pnpm format
```

---

## 15. Next Steps After Setup

### Phase 1: Core Authentication & Projects
1. Implement user registration and login
2. Create project CRUD operations
3. Build basic frontend for auth and project management

### Phase 2: Document Processing
1. Add document upload endpoint
2. Implement PDF/DOCX parsing
3. Create chunking logic
4. Set up embedding generation

### Phase 3: RAG Pipeline
1. Implement vector storage with ChromaDB
2. Build retrieval logic
3. Create RAG prompt templates
4. Implement LLM provider factory

### Phase 4: Chat Interface
1. Build chat UI with message history
2. Implement streaming responses
3. Add source citations
4. Polish UX with loading states

### Phase 5: Refinement
1. Add error handling and validation
2. Improve UI/UX
3. Add basic tests
4. Document API usage

---

## 16. Extension Points (Future)

When you're ready to scale, add these in order:
1. **Background Workers**: Move document processing to Celery/RQ
2. **Caching**: Add Redis for response caching
3. **Multi-user Projects**: Add collaboration features
4. **Export**: Markdown/PDF export functionality
5. **Advanced Retrieval**: Hybrid search, re-ranking
6. **Observability**: Logging, metrics, tracing
7. **Production Deploy**: K8s manifests, CI/CD pipelines

---

## 17. Design Decisions & Rationale

| Decision | Rationale |
|----------|-----------|
| Synchronous processing first | Simpler to debug, good enough for MVP |
| Embedded ChromaDB | No extra service to manage locally |
| Feature-based frontend | Scales better than type-based organization |
| Service layer in backend | Clean separation between API and business logic |
| Model-agnostic design | Easy to switch or compare LLM providers |
| Monorepo | Shared types, easier refactoring |
| Docker for dev | Consistent environment across team |

---

*This boilerplate prioritizes simplicity and rapid development. Add complexity only when you need it.*
---
# ARCHITECTURE.md

# NotebookLM Simplified — Architecture Documentation

## 1. Overview
NotebookLM Simplified is a full-stack application inspired by Google’s NotebookLM. It allows users to:
- Log in securely
- Create and manage notebooks
- Upload or connect documents
- Interact with an AI assistant (LLM) through conversational “steps”
- View, resume, and organize AI reasoning across notebooks

Each user owns multiple notebooks, each notebook contains multiple steps, and optionally references documents as data sources.

## 2. System Architecture
### 2.1 High-Level Diagram
```
Frontend (Vite + React + TS + Tailwind)
        │
        ▼
FastAPI Backend (Python + LangChain)
        │
        ▼
PostgreSQL Database (SQLModel ORM)
```

### 2.2 Components
| Layer | Description | Key Technologies |
|-------|--------------|------------------|
| Frontend | Interactive UI for managing notebooks, documents, and AI chats | Vite, React, TypeScript, TailwindCSS, React Query, Zustand |
| Backend API | Handles user authentication, notebook & step management, LLM queries | FastAPI, LangChain, SQLModel, JWT Auth |
| Database | Stores all persistent entities (users, notebooks, steps, documents) | PostgreSQL |
| LLM Layer | Manages retrieval-augmented generation and context reasoning | LangChain, OpenAI API (or local LLM) |
| Storage | File/document uploads | AWS S3, Google Cloud Storage, or local FS |
| Auth System | JWT-based or OAuth (Google Sign-In) | FastAPI Users / Authlib |

## 3. Data Model Overview
**Entities**
- User: Owns notebooks and documents.
- Notebook: Collection of AI interactions (steps) around one topic.
- Step: One reasoning/action exchange (user input + AI output).
- Document: Optional uploaded or linked file used as a knowledge source.

**Relationships**
```
User ──< Notebook ──< Step
  │
  └──< Document
```

## 4. Backend Architecture
### 4.1 Layers
1. API Layer (FastAPI Routers)
   - /auth — Login, register, logout
   - /notebooks — CRUD for notebooks
   - /steps — Create, list, regenerate steps
   - /documents — Upload and manage files

2. Service Layer
   - llm_service.py — handles LangChain chains & embeddings
   - notebook_service.py — orchestrates notebook operations
   - auth_service.py — manages user JWT tokens

3. Persistence Layer
   - SQLModel ORM models (User, Notebook, Step, Document)
   - Database session via dependency injection

4. LLM Integration
   - Uses LangChain RunnableSequence or ConversationalRetrievalChain
   - Optional vector DB (FAISS / Chroma) for document embeddings

## 5. Frontend Architecture
### 5.1 Directory Structure
```
src/
 ├─ components/
 │   ├─ NotebookList.tsx
 │   ├─ StepCard.tsx
 │   ├─ ChatInput.tsx
 │   └─ Navbar.tsx
 ├─ pages/
 │   ├─ Login.tsx
 │   ├─ Register.tsx
 │   ├─ NotebookView.tsx
 │   └─ Dashboard.tsx
 ├─ store/
 │   └─ useNotebookStore.ts
 ├─ api/
 │   └─ client.ts
 ├─ utils/
 │   └─ auth.ts
 ├─ App.tsx
 └─ main.tsx
```

### 5.2 State Management
- React Query: Server data fetching and caching
- Zustand: Local UI and session state
- JWT stored in HttpOnly cookies or local storage

### 5.3 User Flow
1. User logs in → JWT issued
2. Frontend fetches /notebooks
3. Selecting a notebook fetches /steps
4. User sends new input → POST /steps triggers LLM → response displayed
5. All interactions stored as “steps” in DB

## 6. Libraries and Tools
| Purpose | Library |
|----------|----------|
| Backend framework | FastAPI |
| Database ORM | SQLModel (built on SQLAlchemy) |
| Auth | FastAPI Users / Authlib |
| LLM & RAG | LangChain, OpenAI |
| DB | PostgreSQL |
| Frontend | React + Vite + TypeScript |
| Styling | TailwindCSS |
| State | Zustand + React Query |
| Build | pnpm + Turborepo |

## 7. Deployment
- Frontend: Vercel or Netlify
- Backend: Fly.io, Render, or AWS EC2
- Database: Supabase / Neon / RDS
- File Storage: S3 or GCS

## 8. Future Extensions
- Notebook sharing and collaboration
- AI-generated notebook summaries
- Embedding search over all notebooks
- Multi-LLM orchestration
- Fine-tuning user preferences per notebook

---

# DATABASE.md

# NotebookLM Simplified — Database Documentation

## 1. Overview
Database is PostgreSQL with SQLModel ORM. Stores Users, Notebooks, Steps, Documents, and Document Chunks.

## 2. Entities and Relationships
### 2.1 User
| Field | Type | Description |
|-------|------|-------------|
| id | int (PK) | Unique user ID |
| email | string | User email, unique |
| hashed_password | string | Bcrypt hashed password |
| is_active | boolean | Active status |
| created_at | timestamp | Creation date |

### 2.2 Notebook
| Field | Type | Description |
|-------|------|-------------|
| id | int (PK) | Notebook ID |
| owner_id | int (FK User.id) | Owner user |
| title | string | Notebook title |
| description | string | Optional description |
| created_at | timestamp | Creation date |

### 2.3 Document
| Field | Type | Description |
|-------|------|-------------|
| id | int (PK) | Document ID |
| notebook_id | int (FK Notebook.id) | Parent notebook |
| filename | string | File name |
| content_type | string | MIME type |
| size | int | File size |
| storage_path | string | Local/S3 path |
| uploaded_at | timestamp | Upload time |

### 2.4 DocumentChunk
| Field | Type | Description |
|-------|------|-------------|
| id | int (PK) | Chunk ID |
| document_id | int (FK Document.id) | Parent document |
| text | string | Chunk text content |
| start_offset | int | Start index in document |
| end_offset | int | End index in document |
| token_count | int | Token count |
| embedding_id | string | Optional vector DB ID |

### 2.5 Step
| Field | Type | Description |
|-------|------|-------------|
| id | int (PK) | Step ID |
| notebook_id | int (FK Notebook.id) | Parent notebook |
| user_id | int (FK User.id) | Owner user |
| input_text | string | User input |
| output_text | string | AI output |
| metadata | JSON | Model info, tokens, etc. |
| created_at | timestamp | Creation date |
| parent_step_id | int | Optional previous step reference |

### 2.6 StepRetrievedChunk
| Field | Type | Description |
|-------|------|-------------|
| id | int (PK) | ID |
| step_id | int (FK Step.id) | Step reference |
| chunk_id | int (FK DocumentChunk.id) | Retrieved chunk |
| score | float | Similarity score |
| snippet | string | Optional excerpt |

---

# API.md

# NotebookLM Simplified — API Documentation

## Base URL
```
/api/v1
```

### Authentication
- `POST /auth/register` — register user (email, password, name)
- `POST /auth/login` — login (email, password) → access_token
- `GET /auth/me` — current authenticated user

### Users
- `GET /users/{id}` — fetch user profile

### Notebooks
- `GET /notebooks` — list notebooks for current user
- `POST /notebooks` — create notebook (title, description)
- `GET /notebooks/{id}` — fetch notebook with steps & documents
- `PATCH /notebooks/{id}` — update notebook metadata
- `DELETE /notebooks/{id}` — delete notebook

### Steps
- `GET /notebooks/{notebook_id}/steps` — list steps
- `POST /notebooks/{notebook_id}/steps` — create new step (input text, optional sources)
- `PATCH /steps/{id}` — edit or regenerate step
- `DELETE /steps/{id}` — delete step

### Documents
- `POST /documents/upload` — upload file (PDF, text)
- `GET /documents` — list all user documents
- `GET /documents/{id}` — fetch specific document

### LLM Operations
- `POST /llm/query` — free-form query (prompt, optional sources)

### Error Handling
All errors return:
```json
{
  "error": "Message describing the issue


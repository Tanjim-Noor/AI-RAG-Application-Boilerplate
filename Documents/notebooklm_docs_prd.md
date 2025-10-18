# PRD.md

# Product Requirements Document (PRD)

## 1. Overview
**Product Name:** NotebookLM Simplified  
**Goal:** A full-stack AI research notebook inspired by Google NotebookLM, designed for step-by-step reasoning, document understanding, and AI-assisted note-taking.

The platform enables users to create notebooks, upload documents, and interact with an LLM to build structured reasoning trails (“steps”). Each notebook maintains its own context, allowing users to pick up where they left off.

---

## 2. Objectives
### 2.1 Primary Goals
- Build an AI notebook where every user↔LLM interaction is saved as a **step**.
- Support **document uploads** and contextual reasoning (RAG via LangChain).
- Provide **persistent user accounts** with notebooks and step history.
- Deliver a **clean, fast, and minimal interface** with real-time step updates.

### 2.2 Secondary Goals
- Enable citation and source tracking.
- Allow notebook-wide search and summarization.
- Support multiple LLM backends.

---

## 3. Target Users
| User Type | Description | Goals |
|------------|--------------|--------|
| Researcher / Student | Uses the system to summarize academic papers | Summarize and cross-reference ideas |
| Writer / Analyst | Uses AI for content drafting or planning | Generate structured content notes |
| Developer | Uses as AI lab notebook | Experiment with ideas and prototypes |

---

## 4. User Stories
| ID | As a... | I want to... | So that... |
|----|----------|--------------|------------|
| US-001 | User | Register and log in | My data stays private and synced |
| US-002 | User | Create a new notebook | I can separate topics or projects |
| US-003 | User | Upload documents | I can reference specific files in conversations |
| US-004 | User | Chat with the LLM | I can ask contextual questions about my documents |
| US-005 | User | View all steps of a notebook | I can track and resume my reasoning process |
| US-006 | User | Delete or edit a step | I can clean up or refine my reasoning trail |
| US-007 | User | Search across notebooks | I can quickly find old insights |
| US-008 | User | Download notebook as markdown | I can export my work |

---

## 5. Functional Requirements
### 5.1 Authentication
- JWT-based login/register/logout endpoints.
- OAuth (Google Sign-In) support.
- Password hashing via bcrypt.

### 5.2 Notebook Management
- CRUD operations for notebooks.
- Notebook list paginated per user.
- Each notebook contains metadata (title, description, created_at).

### 5.3 Step System
- Create, retrieve, and delete steps.
- Each step stores user prompt, AI response, timestamp, and references.
- Steps persist even after page refresh.
- LLM pipeline triggered via LangChain chain per step.

### 5.4 Document Management
- File upload endpoint.
- Support PDF, TXT, DOCX.
- Parse and chunk files for embedding.
- Maintain mapping between documents and notebooks.

### 5.5 LLM Integration
- Uses LangChain for orchestration.
- ConversationalRetrievalChain or RunnableSequence for context.
- Embedding storage via FAISS or Chroma.
- Integration with OpenAI API (configurable).

### 5.6 UI / UX
- Responsive web interface (React + Tailwind).
- Chat-like interface per notebook.
- Sidebar for notebook/document management.
- Real-time rendering of LLM responses (streaming optional).
- Search and filter features.

### 5.7 API Layer
Endpoints:
- `/auth/*` — authentication
- `/notebooks/*` — notebook CRUD
- `/steps/*` — step CRUD and generation
- `/documents/*` — upload and retrieval
- `/llm/query` — generic AI prompt endpoint

---

## 6. Non-Functional Requirements
| Category | Requirement |
|-----------|-------------|
| **Performance** | API response under 300ms (excluding LLM latency) |
| **Scalability** | Horizontal scaling of FastAPI via async workers |
| **Security** | HTTPS, JWT Auth, input sanitization |
| **Availability** | 99.9% uptime target |
| **Storage** | Documents stored on S3-compatible service |
| **Maintainability** | Code structured with service and model layers |

---

## 7. Tech Stack
| Layer | Technology |
|--------|-------------|
| Frontend | Vite + React + TypeScript + TailwindCSS |
| State Management | Zustand + React Query |
| Backend | FastAPI + LangChain + SQLModel |
| Database | PostgreSQL |
| ORM | SQLModel (SQLAlchemy Core) |
| Auth | FastAPI Users / Authlib |
| Vector DB | FAISS / Chroma |
| File Storage | AWS S3 / GCS |
| Deployment | Vercel (frontend), Fly.io / Render (backend) |

---

## 8. Data Flow
1. User logs in → receives JWT.
2. Frontend fetches `/notebooks` list.
3. User selects a notebook → fetches `/steps` and `/documents`.
4. User enters prompt → POST `/steps` triggers LLM chain.
5. Response stored in DB → returned to frontend → rendered live.
6. Documents uploaded via `/documents/upload`, chunked, and embedded for retrieval.

---

## 9. Database Schema Summary
Entities: `User`, `Notebook`, `Step`, `Document`, `DocumentChunk`.
Relationships:
```
User ──< Notebook ──< Step
  │
  └──< Document ──< DocumentChunk
```

---

## 10. User Experience Flow
1. **Login/Register** → Access dashboard.
2. **Dashboard** → List of notebooks.
3. **Select notebook** → Preload steps.
4. **Chat with AI** → Steps appear in timeline.
5. **Upload documents** → Documents indexed.
6. **Search / summarize / export** → Optional features.

---

## 11. Risks and Mitigations
| Risk | Mitigation |
|------|-------------|
| High LLM latency | Use async streaming and caching |
| Large document size | Chunk and limit file size |
| Data loss | Scheduled DB backups |
| Unauthorized access | JWT expiry + refresh tokens |

---

## 12. Success Metrics
| Metric | Target |
|--------|---------|
| User retention | 80% after 7 days |
| Notebook load time | <1s average |
| API uptime | 99.9% |
| LLM accuracy satisfaction | ≥85% positive feedback |

---

## 13. Future Enhancements
- Collaborative editing and notebook sharing.
- Multi-LLM routing (Anthropic, Gemini, etc.).
- Offline export and import.
- In-app analytics and recommendation system.

---

## 14. Appendix
**Version:** 1.0.0  
**Author:** Tanjim Noor  
**Date:** 2025-10-17  
**Status:** Draft


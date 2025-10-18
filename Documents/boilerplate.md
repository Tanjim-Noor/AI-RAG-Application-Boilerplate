# BOILERPLATE.md

# Full‑stack AI Project Boilerplate — Template & Architecture

## 1. Goal (one-liner)
Provide a well-documented, reusable starting point for small teams to rapidly build Full‑stack AI web prototypes (RAG/LLM apps like NotebookLM), while ensuring clean separation of concerns for future scaling and reuse across multiple similar projects.

## 2. Context
You plan to run multiple projects with similar scope (document ingestion, retrieval, LLM-assisted workflows). The boilerplate should minimize repeated setup, enforce patterns that scale, and support rapid proof‑of‑concept development with a low developer count.

## 3. Principles & constraints
- **Separation of Concerns**: clear boundaries between frontend, backend, ingestion, vector store, and workers.  
- **Reusability**: share logic and types across projects via packages.  
- **Simplicity first**: sensible defaults for fast prototyping; opt-in advanced features.  
- **Modularity**: each service/component can be swapped or scaled independently.  
- **Low ops burden**: works locally with minimal infra and smoothly migrates to cloud.

---

## 4. Most common features (shortlist)
- User auth & account management (register/login/JWT)  
- Notebook CRUD (project container)  
- Steps timeline (user input + LLM output)  
- Document upload & parsing (PDF/TXT/DOCX)  
- Chunking & embedding pipeline (with batching + dedupe)  
- Vector store integration (Chroma/FAISS/Weaviate)  
- Retriever + RAG orchestration using LangChain  
- Background workers for ingest/embedding (Celery/RQ)  
- Streaming LLM responses (SSE/WebSockets)  
- Export (Markdown/PDF) and citation links  
- Usage metrics / token accounting / rate limiting

---

## 5. Common libraries & infrastructure choices (recommended)
### Frontend
- React + TypeScript (core) — UI, component safety.  
- Vite — fast dev & build for SPA.  
- Tailwind CSS — utility-first styling.  
- React Query (TanStack) — server state caching and retries.  
- React Router — routing.  
- Zustand (optional) — local UI state.  
- react-markdown / Lexical — rich text or markdown rendering/editing.  

### Backend (Python)
- FastAPI — lightweight async API framework.  
- LangChain — LLM orchestration and common pipelines.  
- SQLModel (or SQLAlchemy + Pydantic) — models & validation.  
- asyncpg + PostgreSQL — relational storage.  
- Chroma / FAISS / Weaviate — vector store (Chroma for simple local POC).  
- Celery + Redis (or RQ) — background workers for ingestion & embedding.  
- Alembic — DB migrations.  
- pypdf / python-docx / bs4 — document parsing.  
- openai / llama-cpp-python / llms provider SDK — LLM endpoints.  

### Devops & tooling
- pnpm + Turborepo (or pnpm workspaces) — monorepo management and script orchestration.  
- Docker + docker-compose — local dev parity.  
- GitHub Actions / GitLab CI — CI pipelines.  
- Sentry / Prometheus + Grafana — observability.  

---

## 6. High-level architecture (concise)
- **Frontend (SPA)** — Vite/React app that calls backend APIs and streams LLM output.  
- **Backend (API)** — FastAPI app exposing REST + optional WebSocket endpoints.  
- **Worker(s)** — background service(s) for CPU- and I/O-bound tasks (document parsing, embeddings, indexing).  
- **Vector Store** — Chroma/FAISS for retrieval.  
- **Database** — PostgreSQL for structured data (users, notebooks, steps, document metadata).  
- **Object Storage** — S3-compatible store for documents and derived artifacts.  

Communications: frontend ↔ backend over HTTPS; backend ↔ workers via Redis (task queue); backend ↔ vector store via SDK/HTTP; backend ↔ LLM provider via SDK/HTTP.

---

## 7. Monorepo & file structure (template)
Keep everything that is logically shared in a single repo. Example layout:

```
repo-root/
├─ apps/
│  ├─ frontend/             # Vite React app
│  └─ backend/              # FastAPI app
├─ services/
│  ├─ workers/              # Celery workers or worker-only services
│  └─ ingestion/            # optional specialized ingestion microservice
├─ packages/
│  ├─ core-types/           # shared TypeScript/Python schema and contract docs
│  ├─ ui/                   # shared React components (optional)
│  └─ utils/                # shared utilities
├─ infra/
│  ├─ docker/               # Dockerfiles & compose for local dev
│  └─ k8s/                  # k8s manifests (optional)
├─ scripts/                 # helper scripts
├─ .env.example
└─ README.md
```

Notes:
- `packages/core-types` houses language-neutral contracts (OpenAPI spec, JSON Schemas) and small generated clients.  
- Keep Python and TypeScript models aligned via schemas (OpenAPI + codegen or JSON Schema → code generation) to avoid drift.

---

## 8. Backend modules & responsibilities (concise)
- **auth**: registration, login, token management, permissions.  
- **notebooks**: CRUD, metadata, collaborator management.  
- **documents**: upload, storage, parsing & chunking orchestration.  
- **embeddings**: batching embedding calls & error handling.  
- **indexing**: upsert vectors to vector store and manage ids.  
- **retrieval**: query vector store, apply filters, return scored chunks.  
- **llm_pipeline**: build prompts, call LLM, handle streaming, post-process.  
- **steps**: create/read/list/regenerate steps (connects retriever + LLM + persistence).  
- **exports**: markdown/pdf export of notebook with citation links.  
- **metrics**: token usage logging, request metrics, rate limiting.

Separation: keep these as separate modules with clear service interfaces (not just flat controllers). This simplifies swapping implementations.

---

## 9. Frontend responsibilities & components (concise)
- **Auth flow**: login/register, token renewal.  
- **Dashboard**: list notebooks, create, delete.  
- **Notebook view**: step timeline, chat input, step detail panel.  
- **Document manager**: upload progress, ingestion status, preview.  
- **Retrieval UI**: show citations, open document offsets.  
- **Streamed rendering**: progressively show model tokens when streaming.  

Components to provide in the template: `NotebookList`, `NotebookView`, `StepCard`, `ChatInput`, `DocumentUploader`, `DocumentViewer`, `AuthProvider`, `ApiClient`.

---

## 10. Contracts, Schemas & API design (concise)
- Expose a versioned REST API (e.g., `/api/v1/`) with predictable resources: `/auth`, `/users`, `/notebooks`, `/documents`, `/steps`, `/llm`.  
- Use OpenAPI (FastAPI auto-generates) as the canonical contract.  
- Keep requests/response shapes simple and small (avoid embedding big source text in Step responses; instead reference snippet ids or document offsets).  
- Provide streaming endpoints for LLM output (SSE or WebSocket) and a finalization callback/response when generation completes.

---

## 11. Dev tooling & scripts (practical)
- `pnpm dev` orchestrates starting frontend + backend + worker (via Turborepo).  
- `make setup` or `scripts/bootstrap.sh` for initial environment (venv, pnpm install, db init).  
- `scripts/reset-db` for local dev testing.  
- `scripts/run-ingest-sample` to run a baseline ingestion example.  

CI:
- Linting (pre-commit hooks): ESLint + Prettier + Ruff/Black + isort.  
- Tests: Jest (frontend), pytest (backend).  
- Pipeline: run unit tests, build, lint, and optionally smoke test API endpoints.

---

## 12. Local development flow (concise)
1. Clone repo & copy `.env.example` → `.env`.  
2. Run bootstrap script to install node/pip deps and create DB.  
3. Start `pnpm dev` to run frontend, backend, and worker.  
4. Upload sample doc, wait for ingestion & embeddings, then run queries.

---

## 13. Production & Deployment recommendations
- Containerize services and use orchestrator (Cloud Run / ECS / Kubernetes) depending on scale.  
- Use managed Postgres (Neon / RDS / Supabase) and managed Redis.  
- Use S3-compatible storage for files.  
- Deploy vector store as a managed service (Weaviate or Milvus) or persistent Chroma/FAISS host.  
- Use an API gateway (Traefik / Nginx) with TLS termination and centralized auth.  
- Externalize secrets (Vault, cloud secrets manager).  

---

## 14. Observability & monitoring (concise)
- Request tracing / metrics: Prometheus + Grafana, instrument FastAPI.  
- Error reporting: Sentry.  
- Usage metrics: record token counts, call durations, and queue backlogs.  
- Alerts: configure SLO-based alerts for queue length and LLM error rates.

---

## 15. Security & compliance (concise)
- Use HTTPS, secure cookies or Authorization headers, short-lived JWTs with refresh tokens.  
- Validate and sanitize uploaded file types and sizes.  
- Rate-limit LLM calls per user and per API key.  
- Audit logs for actions (document upload, step creation, exports).  
- Data retention policies and optional encryption at rest for PII.

---

## 16. Scaling & extensibility tips
- **Separation of stateful services**: DB, vector store, file store should be managed services.  
- **Horizontally scale** stateless API workers.  
- **Shard or namespace vector store** by tenant for multi-tenant scaling.  
- **Caching**: cache retriever results for frequently asked queries.  
- **Batching**: batch embedding calls to optimize costs.  

---

## 17. Reuse & templating strategy
- Keep a `project-template` folder with a minimal working example (frontend + backend + basic ingestion).  
- Provide generators (Yeoman or simple shell script) to copy + rename template and bootstrap env.  
- Maintain `packages/core-types` for cross-language models and keep it versioned semantically.

---

## 18. Minimal POC checklist (what to implement first)
1. Auth (register/login with JWT).  
2. Notebook CRUD + frontend list & create.  
3. Document upload + store metadata.  
4. Simple chunking & store chunks in DB.  
5. Embed chunks using OpenAI or local model and store vectors (Chroma).  
6. POST `/notebooks/{id}/steps` that runs retrieval + LLM and returns a stored Step.  
7. Frontend notebook view showing steps and streaming response.  
8. Background worker setup for ingestion jobs.

---

## 19. Trade-offs & decisions (concise justification)
- **Chroma vs Weaviate vs FAISS**: pick Chroma for local POC simplicity; migrate to Weaviate/Milvus for scale.  
- **Monorepo vs multi-repo**: monorepo gives faster dev & shared types; split later if teams grow.  
- **LangChain**: accelerates RAG patterns and offers common building blocks; vendor lock-in is low because it's a library.

---

## 20. Next steps (practical)
- Create the minimal project template implementing the POC checklist.  
- Add `README` + developer onboarding docs.  
- Add codegen for shared schemas (OpenAPI → client types).  
- Prepare a small demo script and sample dataset for onboarding new engineers.

---

*End of Boilerplate Template*


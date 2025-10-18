# Phase 1: Backend Foundation

## Objective
Build the FastAPI backend foundation with database models, authentication system, and proper application structure following clean architecture principles.

## Context
You now have a working monorepo with basic FastAPI and React scaffolds. This phase focuses on creating the backend infrastructure needed for a multi-user RAG application: user management, authentication, and database structure.

## Requirements

### Database Models Needed
- **User**: For authentication and ownership
- **Project**: Container for documents and conversations (like NotebookLM notebooks)
- **Document**: Uploaded files with metadata
- **Message**: Chat history (user questions and AI responses)

### Authentication Requirements
- JWT-based authentication
- Password hashing with bcrypt
- Token expiration and refresh capability
- Protected route dependencies

### API Structure
Follow a layered architecture:
- **API Layer** (`app/api/`): Route definitions, request/response handling
- **Service Layer** (`app/services/`): Business logic orchestration
- **Core Layer** (`app/core/`): Utilities, security, helpers
- **Models Layer** (`app/models/`): Database schemas
- **Schemas Layer** (`app/schemas/`): Pydantic validation models

## Directory Structure to Complete

```
apps/backend/app/
├── main.py                    # Update with routers
├── config.py                  # Settings using pydantic-settings
├── database.py                # Database connection and session
│
├── api/
│   ├── __init__.py
│   ├── deps.py               # Dependency injection (auth, db session)
│   └── v1/
│       ├── __init__.py       # API router aggregation
│       ├── auth.py           # Auth endpoints (register, login, refresh)
│       ├── users.py          # User profile endpoints
│       └── health.py         # Health check endpoints
│
├── core/
│   ├── __init__.py
│   ├── security.py           # JWT, password hashing utilities
│   └── exceptions.py         # Custom exception classes
│
├── models/
│   ├── __init__.py
│   ├── base.py              # Base model with common fields
│   ├── user.py              # User SQLModel
│   ├── project.py           # Project SQLModel
│   ├── document.py          # Document SQLModel
│   └── message.py           # Message SQLModel
│
├── schemas/
│   ├── __init__.py
│   ├── auth.py              # Login, Register, Token schemas
│   ├── user.py              # User response schemas
│   ├── project.py           # Project schemas (later phase)
│   ├── document.py          # Document schemas (later phase)
│   └── message.py           # Message schemas (later phase)
│
└── services/
    ├── __init__.py
    ├── auth_service.py      # Authentication business logic
    └── user_service.py      # User management business logic

alembic/
├── env.py                   # Configure to use SQLModel
├── script.py.mako
└── versions/
    └── (migrations will be here)

alembic.ini                  # Alembic configuration
```

## Tasks

### 1. Configuration Setup (config.py)

Create a Settings class using pydantic-settings that loads from environment:
- **Database**: `DATABASE_URL` with PostgreSQL connection string
- **JWT Settings**: 
  - `SECRET_KEY` for signing tokens
  - `ALGORITHM` (default: "HS256")
  - `ACCESS_TOKEN_EXPIRE_MINUTES` (default: 30)
- **CORS Settings**: List of allowed origins (include frontend URL)
- **File Settings**: 
  - `UPLOAD_DIR` for file storage
  - `MAX_UPLOAD_SIZE_MB`
- **LLM Settings**: Provider configuration (placeholders for now)

Use `@lru_cache` decorator to create singleton settings instance

### 2. Database Setup (database.py)

Implement database connection using SQLModel:
- Create async engine from DATABASE_URL
- Configure engine with:
  - Echo SQL statements in development
  - Pool size and overflow settings
  - Connection pool pre-ping
- Create async session maker
- Implement `get_session` dependency that yields session
- Add `create_db_and_tables` function (for testing, migrations will be primary method)

### 3. Base Model (models/base.py)

Create a SQLModel base class with common fields:
- `id`: UUID primary key with default uuid4
- `created_at`: DateTime with server default
- `updated_at`: DateTime with onupdate trigger

All other models will inherit from this

### 4. User Model (models/user.py)

Create User SQLModel with fields:
- Inherits from base model (id, created_at, updated_at)
- `email`: String, unique, indexed, not nullable
- `hashed_password`: String, not nullable
- `is_active`: Boolean, default True
- `is_superuser`: Boolean, default False
- `full_name`: Optional string

Define relationships:
- `projects`: Relationship to Project model (one-to-many)
- Configure cascade delete behavior

Add table configuration with proper indexes

### 5. Project Model (models/project.py)

Create Project SQLModel with fields:
- Inherits from base model
- `name`: String, not nullable
- `description`: Optional text field
- `user_id`: UUID foreign key to User, not nullable, indexed
- `settings`: Optional JSON field for project-specific configuration

Define relationships:
- `user`: Relationship back to User
- `documents`: Relationship to Document model (one-to-many)
- `messages`: Relationship to Message model (one-to-many)

Add appropriate indexes and cascade rules

### 6. Document Model (models/document.py)

Create Document SQLModel with fields:
- Inherits from base model
- `project_id`: UUID foreign key to Project, not nullable, indexed
- `filename`: String, not nullable
- `file_path`: String, not nullable (relative path to stored file)
- `file_type`: String (e.g., "pdf", "docx", "txt")
- `file_size`: Integer (bytes)
- `status`: String with enum-like values ("uploading", "processing", "completed", "failed")
- `error_message`: Optional text for error details
- `chunk_count`: Optional integer (number of chunks created)
- `metadata`: Optional JSON field for additional info

Define relationships:
- `project`: Relationship back to Project

Add indexes on status and project_id

### 7. Message Model (models/message.py)

Create Message SQLModel with fields:
- Inherits from base model
- `project_id`: UUID foreign key to Project, not nullable, indexed
- `role`: String (enum-like: "user" or "assistant")
- `content`: Text field, not nullable
- `sources`: Optional JSON field (list of source citations with document_id, chunk_id, score)
- `token_count`: Optional integer
- `model_used`: Optional string (which LLM model generated this)
- `generation_time_ms`: Optional integer (response time)

Define relationships:
- `project`: Relationship back to Project

Add indexes on project_id and created_at for efficient history retrieval

Ensure messages are ordered by created_at by default

### 8. Security Utilities (core/security.py)

Implement authentication and security functions:

**Password Hashing**:
- `get_password_hash(password: str) -> str`: Hash password using bcrypt
- `verify_password(plain_password: str, hashed_password: str) -> bool`: Verify password

**JWT Token Functions**:
- `create_access_token(data: dict, expires_delta: Optional[timedelta]) -> str`: Create JWT token
  - Include user_id and expiration in payload
  - Sign with SECRET_KEY and ALGORITHM from settings
  - Default expiration from settings if not provided
- `decode_access_token(token: str) -> dict`: Decode and validate JWT
  - Handle expiration
  - Verify signature
  - Return payload or raise exception

**Token Data Model**:
- Create TokenData schema for validated token payload
- Include user_id and expiration fields

### 9. Custom Exceptions (core/exceptions.py)

Define custom exception classes:
- `AuthenticationError`: For failed authentication
- `AuthorizationError`: For insufficient permissions
- `ResourceNotFoundError`: For 404 scenarios
- `ValidationError`: For input validation failures
- `DocumentProcessingError`: For document handling errors

Each exception should:
- Inherit from appropriate base exception
- Include status_code attribute
- Include detail message
- Be compatible with FastAPI exception handlers

### 10. Authentication Schemas (schemas/auth.py)

Create Pydantic schemas for authentication:

**UserRegister**:
- email: EmailStr, validated format
- password: String with minimum length validation (8+ chars)
- full_name: Optional string

**UserLogin**:
- email: EmailStr
- password: String

**Token**:
- access_token: String
- token_type: String (default "bearer")

**TokenData**:
- user_id: UUID
- exp: Optional datetime

### 11. User Schemas (schemas/user.py)

Create Pydantic schemas for user responses:

**UserBase**:
- email: EmailStr
- full_name: Optional string

**UserCreate**:
- Inherits from UserBase
- password: String

**UserResponse**:
- Inherits from UserBase
- id: UUID
- is_active: Boolean
- created_at: DateTime
- Exclude hashed_password from response

**UserUpdate**:
- email: Optional EmailStr
- full_name: Optional string
- password: Optional string

Configure Pydantic model config to work with ORM models

### 12. Dependency Injection (api/deps.py)

Create reusable dependencies:

**get_db**:
- Async dependency that yields database session
- Handles session lifecycle (commit/rollback/close)

**get_current_user**:
- Async dependency that:
  - Extracts JWT token from Authorization header
  - Validates token using security utilities
  - Queries database for user by ID
  - Raises 401 if token invalid or user not found
  - Returns User model instance

**get_current_active_user**:
- Depends on get_current_user
- Additional check for is_active status
- Raises 403 if user inactive

Dependencies should use FastAPI's Depends and proper type hints

### 13. Auth Service (services/auth_service.py)

Create AuthService class with methods:

**register_user**:
- Parameters: email, password, full_name (optional), db session
- Validate email is not already registered
- Hash password using security utilities
- Create user in database
- Return created user model
- Handle duplicate email error gracefully

**authenticate_user**:
- Parameters: email, password, db session
- Query user by email
- Verify password using security utilities
- Return user if valid, None if invalid
- Check is_active status

**create_tokens_for_user**:
- Parameters: user model
- Create access token with user_id
- Return Token schema with access_token and token_type

### 14. User Service (services/user_service.py)

Create UserService class with methods:

**get_user_by_id**:
- Parameters: user_id, db session
- Query user by ID
- Return user or raise ResourceNotFoundError

**get_user_by_email**:
- Parameters: email, db session
- Query user by email
- Return user or None

**update_user**:
- Parameters: user_id, update_data, db session
- Query user
- Update fields from update_data
- If password in update_data, hash it before saving
- Commit changes
- Return updated user

**delete_user**:
- Parameters: user_id, db session
- Query user
- Delete user (cascades to related records)
- Commit

### 15. Auth API Routes (api/v1/auth.py)

Create FastAPI router with endpoints:

**POST /register**:
- Request body: UserRegister schema
- Calls auth_service.register_user
- Returns UserResponse and 201 status
- Handles duplicate email (400 error)

**POST /login**:
- Request body: UserLogin schema (or OAuth2PasswordRequestForm for compatibility)
- Calls auth_service.authenticate_user
- If valid, creates tokens and returns Token schema
- If invalid, returns 401 with appropriate message

**GET /me**:
- Protected endpoint (requires get_current_active_user dependency)
- Returns UserResponse for current user
- No additional logic needed, dependency handles authentication

**POST /refresh** (optional for later):
- Placeholder for token refresh logic
- Returns new access token

Configure router with prefix "/auth" and tags for documentation

### 16. Health API Routes (api/v1/health.py)

Create router with health check endpoints:

**GET /**:
- Returns basic health status
- Include API version
- Include timestamp

**GET /db**:
- Checks database connectivity
- Executes simple query (SELECT 1)
- Returns database status
- Catches connection errors

Configure router with prefix "/health" and tags

### 17. API Router Aggregation (api/v1/__init__.py)

Create main API router that includes:
- Auth router
- Health router
- Configure with prefix "/v1"

### 18. Update Main Application (main.py)

Update the FastAPI app to include:

**CORS Middleware**:
- Add CORSMiddleware with allowed origins from settings
- Allow credentials, methods, and headers

**Exception Handlers**:
- Add handlers for custom exceptions
- Return appropriate status codes and error responses
- Include validation error handling

**Router Registration**:
- Include v1 API router with prefix "/api"
- Root endpoint returns welcome message

**Startup Event**:
- Log application startup
- Print available routes in development mode

**Metadata**:
- Set title: "AI RAG Boilerplate API"
- Set version: "1.0.0"
- Set description: Brief description of API

### 19. Alembic Configuration

Setup Alembic for database migrations:

**alembic.ini**:
- Configure sqlalchemy.url to use DATABASE_URL from environment
- Set script_location to "alembic"
- Configure logging

**alembic/env.py**:
- Import all SQLModel models
- Set target_metadata to SQLModel.metadata
- Configure async migrations
- Implement run_migrations_offline and run_migrations_online
- Include logic to load environment variables

**Create Initial Migration**:
- Generate first migration with all models
- Name it: "initial_schema"
- Review auto-generated migration
- Include indexes and constraints

### 20. Environment Updates

Update `.env.example` with:
- Detailed comments for each variable
- Example values (with placeholders for secrets)
- Required vs optional variables marked clearly

## Validation Checklist

After completing this phase, verify:

Database:
- [ ] `alembic upgrade head` creates all tables
- [ ] Can connect to PostgreSQL and see tables (users, projects, documents, messages)
- [ ] All foreign keys and indexes are created
- [ ] UUIDs generate correctly as primary keys

Authentication:
- [ ] Can register new user via POST /api/v1/auth/register
- [ ] Password is hashed in database (not plain text)
- [ ] Cannot register duplicate email (gets 400 error)
- [ ] Can login with valid credentials via POST /api/v1/auth/login
- [ ] Login returns valid JWT token
- [ ] Cannot login with invalid credentials (gets 401 error)
- [ ] Can access GET /api/v1/auth/me with valid token
- [ ] Cannot access protected endpoints without token (gets 401 error)
- [ ] Cannot access protected endpoints with invalid token (gets 401 error)

API Documentation:
- [ ] Visit http://localhost:8000/docs shows all endpoints
- [ ] Can test auth endpoints from Swagger UI
- [ ] Schema documentation is complete and accurate
- [ ] Health check endpoints respond correctly

Code Quality:
- [ ] All imports resolve correctly
- [ ] Type hints are present on all functions
- [ ] No linting errors (`make lint`)
- [ ] Services are properly separated from routes
- [ ] Database sessions close properly

## Expected API Structure

After completion, you should have these endpoints:

```
POST   /api/v1/auth/register       - Register new user
POST   /api/v1/auth/login          - Login and get token
GET    /api/v1/auth/me             - Get current user info

GET    /api/health/                - Basic health check
GET    /api/health/db              - Database health check

GET    /                           - Welcome message
GET    /docs                       - Auto-generated API docs
GET    /redoc                      - Alternative API docs
```

## Testing Instructions

Manual testing sequence:

1. Start backend: `pnpm --filter backend dev`
2. Open http://localhost:8000/docs
3. Register a new user with email and password
4. Verify user created (check database or call /auth/me with token)
5. Login with registered credentials
6. Copy access token from response
7. Click "Authorize" in Swagger UI, paste token
8. Call /auth/me endpoint, verify it returns user info
9. Remove token, verify /auth/me returns 401

## Common Issues to Address

- Ensure async/await is used consistently with database operations
- Handle database connection errors gracefully
- Validate all user input with Pydantic schemas
- Return appropriate HTTP status codes
- Include helpful error messages in responses
- Ensure passwords are never logged or returned in responses
- Set up proper CORS to allow frontend requests
- Use environment variables for all configuration
- Handle JWT expiration errors properly

## Notes for AI Assistant

- Use SQLModel throughout for database models (not pure SQLAlchemy)
- All database operations should be async
- Follow FastAPI best practices for dependency injection
- Use Pydantic V2 features (model_config, Field, etc.)
- Ensure proper separation of concerns (routes vs services vs core)
- Add docstrings to all functions explaining purpose
- Use type hints everywhere for better IDE support
- Handle errors at the appropriate layer (service layer for business logic errors)
- Keep routes thin - delegate logic to services
- Use async/await consistently
- Return proper HTTP status codes (201 for created, 204 for no content, etc.)
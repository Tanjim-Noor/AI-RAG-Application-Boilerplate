# Phase 8: RAG Pipeline

## Objective
Build the complete Retrieval-Augmented Generation (RAG) pipeline that combines document retrieval with LLM generation to provide context-aware responses to user queries.

## Context
You now have:
- Documents uploaded, parsed, and chunked
- Chunks embedded and stored in ChromaDB
- Vector similarity search working
- LLM providers integrated with streaming support

This phase connects all these pieces into a cohesive RAG system.

## Requirements

### RAG Pipeline Components
- Query embedding generation
- Context retrieval from vector store
- Prompt template system
- Context injection and formatting
- LLM generation with retrieved context
- Source citation tracking
- Response formatting

### Quality Considerations
- Relevant context selection (top-k with score threshold)
- Context size management (token limits)
- Prompt engineering for best results
- Citation accuracy and traceability
- Error handling at each stage

## Directory Structure

```
apps/backend/app/core/rag/
├── __init__.py
├── pipeline.py              # Main RAG orchestrator
├── prompts.py               # Prompt templates
├── context_builder.py       # Context formatting
└── types.ts                 # RAG-specific types

apps/backend/app/services/
└── rag_service.py           # RAG business logic layer
```

## Tasks

### 1. RAG Types and Models (core/rag/types.py)

Define data structures:

**RetrievedChunk**:
- chunk_id: String (reference to chunk in database)
- document_id: UUID
- document_name: String
- content: String (the chunk text)
- score: Float (similarity score)
- metadata: Dict (any additional info)

**RAGContext**:
- chunks: List of RetrievedChunk
- total_chunks: Integer
- query: String (original query)
- sources_summary: String (formatted source list)

**RAGRequest**:
- query: String
- project_id: UUID
- max_chunks: Integer (default 5)
- score_threshold: Float (default 0.7)
- include_chat_history: Boolean (default True)
- system_prompt_override: Optional string

**RAGResponse**:
- answer: String
- sources: List of RetrievedChunk
- model_used: String
- token_count: Integer
- generation_time_ms: Integer
- context_used: Boolean (whether context was relevant enough)

### 2. Prompt Templates (core/rag/prompts.py)

Create prompt template system:

**SystemPromptTemplate**:
- Base system prompt defining assistant behavior
- Instructions on using provided context
- Guidelines for citations
- Tone and style instructions
- Limitations acknowledgment

Example structure:
"You are an AI assistant analyzing documents. You will be provided with relevant excerpts from documents. Base your answers on this context. If the context doesn't contain relevant information, say so. Always cite sources using [Document Name]."

**Context Formatting Template**:
- Template for formatting retrieved chunks
- Include document name, chunk number, content
- Numbered or bulleted format
- Clear separation between chunks

Example:
```
Context from your documents:

[1] From "Document A.pdf":
{chunk_content}

[2] From "Document B.pdf":
{chunk_content}
```

**User Query Template**:
- Template combining user question with context
- Clear instruction to use context
- Reminder about citations

**No Context Template**:
- Fallback when no relevant context found
- Polite explanation that documents don't contain relevant info
- Suggestion to upload relevant documents

**Chat History Template**:
- Format for including previous messages
- Condensed format to save tokens
- Only recent N messages

Create functions:
- `build_system_prompt(custom_instructions: Optional[str]) -> str`
- `format_context(chunks: List[RetrievedChunk]) -> str`
- `build_user_message(query: str, context: str, chat_history: Optional[List]) -> str`
- `build_no_context_response(query: str) -> str`

### 3. Context Builder (core/rag/context_builder.py)

Create ContextBuilder class with methods:

**select_relevant_chunks**:
- Parameters: all retrieved chunks, score threshold, max chunks
- Filter chunks by score threshold
- Sort by score (highest first)
- Take top-k chunks
- Return filtered list
- Log how many chunks were filtered out

**deduplicate_chunks**:
- Parameters: list of chunks
- Remove duplicate content (same or very similar text)
- Use string similarity or exact match
- Keep highest-scoring version of duplicates
- Return deduplicated list

**manage_context_length**:
- Parameters: chunks, max_tokens (target)
- Estimate tokens per chunk
- Keep adding chunks until approaching token limit
- Prioritize higher-scoring chunks
- Return trimmed list with token estimate

**build_rag_context**:
- Parameters: chunks, query, max_chunks, score_threshold, max_tokens
- Orchestrates: filter -> deduplicate -> trim -> format
- Returns RAGContext object with:
  - Selected chunks
  - Formatted context string
  - Metadata about selection

**extract_document_info**:
- Parameters: chunks
- Extract unique document names and IDs
- Create summary of sources used
- Return formatted source list

### 4. RAG Pipeline (core/rag/pipeline.py)

Create RAGPipeline class with:

**Constructor**:
- Dependencies: embeddings service, retriever, llm provider
- Configuration: default parameters from settings

**embed_query**:
- Parameters: query string
- Generate embedding vector for user query
- Use same embedding model as documents
- Return embedding vector
- Handle errors

**retrieve_context**:
- Parameters: query embedding, project_id, k, filters
- Query vector store for similar chunks
- Apply project_id filter
- Get top-k results with scores
- Convert to RetrievedChunk objects
- Handle empty results

**prepare_prompt**:
- Parameters: query, context, chat_history, system_prompt_override
- Build system prompt
- Format context section
- Include chat history if provided
- Build final user message
- Return messages list in LLM format

**generate_response**:
- Parameters: messages, stream flag
- Call LLM provider
- If streaming, return async generator
- If not streaming, return complete response
- Track token usage
- Track generation time
- Handle LLM errors

**process_query** (main method):
- Parameters: RAGRequest
- Steps:
  1. Embed the query
  2. Retrieve relevant chunks
  3. Build context (filter, deduplicate, trim)
  4. Check if context meets quality threshold
  5. If no quality context, return no-context response
  6. Prepare prompts with context
  7. Generate response
  8. Extract citations from response
  9. Return RAGResponse with sources
- Comprehensive error handling at each step
- Logging for debugging

**stream_response** (for streaming):
- Parameters: RAGRequest
- Similar to process_query but yields chunks
- Yields both text chunks and metadata separately
- Final chunk includes sources

### 5. RAG Service (services/rag_service.py)

Create RAGService class bridging API and core:

**query_with_rag**:
- Parameters: project_id, query, user_id, db session, additional options
- Validate user has access to project
- Create RAG pipeline instance
- Call pipeline.process_query
- Store query and response as Message records
- Link sources to message (via message.sources JSON field)
- Return response with database IDs

**query_with_rag_stream**:
- Parameters: same as above
- Yields streaming response chunks
- Accumulates full response for database storage
- After streaming complete, store message
- Final yield includes message_id

**get_project_context_stats**:
- Parameters: project_id, db session
- Count total documents
- Count total chunks
- Calculate average chunk size
- Return statistics for UI display

**regenerate_response**:
- Parameters: message_id, db session
- Retrieve original query from message
- Rerun RAG pipeline
- Update message with new response
- Return updated response

**adjust_retrieval_parameters**:
- Parameters: project_id, new_parameters
- Allow per-project customization of:
  - Number of chunks retrieved
  - Score threshold
  - Context length limits
- Store in project.settings JSON field

### 6. Message Source Tracking

Enhance Message model handling:

**Source JSON Structure**:
```json
{
  "chunks": [
    {
      "chunk_id": "uuid",
      "document_id": "uuid",
      "document_name": "file.pdf",
      "content_preview": "First 200 chars...",
      "score": 0.89,
      "position": 1
    }
  ],
  "retrieval_params": {
    "k": 5,
    "threshold": 0.7,
    "total_retrieved": 5,
    "total_used": 3
  }
}
```

Create helper methods:
- `format_sources_for_storage(chunks: List[RetrievedChunk]) -> dict`
- `parse_sources_from_storage(sources_json: dict) -> List[RetrievedChunk]`

### 7. Prompt Engineering Best Practices

Implement quality prompt patterns:

**System Prompt Guidelines**:
- Clear role definition
- Explicit context usage instructions
- Citation format specification
- Handling of out-of-context queries
- Tone and style guidelines
- Safety and accuracy emphasis

**Context Presentation**:
- Clear demarcation of context section
- Source attribution for each chunk
- Logical ordering (by relevance)
- Concise formatting to save tokens

**User Query Formatting**:
- Preserve original query
- Add retrieval-specific instructions
- Request explicit citations
- Encourage direct quotations

**Few-Shot Examples** (optional):
- Include example Q&A pairs in system prompt
- Show desired citation format
- Demonstrate handling of uncertain cases

### 8. Advanced Features

**Query Preprocessing**:
- Spell check user queries
- Expand acronyms/abbreviations
- Rephrase for better retrieval
- Extract key entities

**Context Reranking**:
- After initial retrieval, rerank by:
  - Semantic similarity
  - Document recency
  - User feedback scores (future)
- Use simple heuristics initially

**Multi-Query Retrieval**:
- Generate multiple variations of user query
- Retrieve for each variation
- Merge and deduplicate results
- Improves recall

**Conversational Context**:
- Include last N messages from chat history
- Condense history to save tokens
- Maintain conversation continuity
- Track topics across turns

**Citation Parsing**:
- Parse LLM response for citation markers
- Match citations to provided sources
- Validate citation accuracy
- Create clickable links in UI

### 9. Configuration and Tuning

Make RAG parameters configurable:

**Default Configuration**:
- max_chunks: 5
- score_threshold: 0.7
- max_context_tokens: 2000
- include_chat_history: True
- chat_history_messages: 5

**Per-Project Overrides**:
- Store in project.settings
- Allow users to tune per project (future UI)

**Environment Variables**:
- RAG_DEFAULT_MAX_CHUNKS
- RAG_DEFAULT_SCORE_THRESHOLD
- RAG_MAX_CONTEXT_TOKENS

### 10. Error Handling

Handle errors gracefully at each stage:

**Embedding Errors**:
- Retry with exponential backoff
- Fall back to keyword search (future)
- Return helpful error message

**Retrieval Errors**:
- Log vector store errors
- Return empty context gracefully
- Notify user of system issue

**LLM Errors**:
- Retry transient errors
- Handle rate limits
- Provide fallback response
- Log for debugging

**Context Building Errors**:
- Handle malformed chunk data
- Skip problematic chunks
- Continue with valid chunks

### 11. Logging and Monitoring

Add comprehensive logging:

**Query Logging**:
- Log all queries with timestamps
- Log retrieval results (count, scores)
- Log context building decisions
- Log LLM parameters used
- Log response times

**Metrics to Track**:
- Average retrieval score
- Context chunks used per query
- Token usage per query
- Response generation time
- Error rates by type

**Debug Information**:
- Log full prompts in development mode
- Log chunk selection decisions
- Log deduplication results
- Redact sensitive info in production

### 12. Testing Strategy

Plan for testing (implementation in Phase 13):

**Unit Tests**:
- Test each component independently
- Mock external dependencies
- Test edge cases (no context, empty query)

**Integration Tests**:
- Test full pipeline end-to-end
- Use test project with known documents
- Verify source attribution
- Test streaming responses

**Quality Tests**:
- Evaluate response relevance
- Check citation accuracy
- Test context selection
- Measure response coherence

## Validation Checklist

After completing this phase, verify:

Core Pipeline:
- [ ] Can embed a query successfully
- [ ] Retrieves relevant chunks from vector store
- [ ] Filters chunks by score threshold
- [ ] Deduplicates similar chunks
- [ ] Manages context length properly
- [ ] Builds formatted context string
- [ ] Generates system prompt correctly
- [ ] Calls LLM with proper message format

Response Generation:
- [ ] Non-streaming responses work
- [ ] Streaming responses work
- [ ] Sources tracked accurately
- [ ] Citations appear in responses
- [ ] Token usage recorded
- [ ] Generation time measured

Quality Checks:
- [ ] Responses reference provided context
- [ ] Responses include citations
- [ ] Irrelevant chunks filtered out
- [ ] Handles queries with no relevant context
- [ ] Chat history included when available
- [ ] Multiple document sources handled

Service Layer:
- [ ] Queries stored as messages in database
- [ ] Sources stored in message.sources field
- [ ] User authorization checked
- [ ] Errors handled gracefully
- [ ] Statistics endpoint works

Integration:
- [ ] Works with OpenAI provider
- [ ] Works with Anthropic provider
- [ ] Context from multiple documents combined
- [ ] Previous chat messages included correctly
- [ ] Configuration overrides work

## Expected Behavior

### Sample RAG Flow:

**User Query**: "What are the main benefits mentioned?"

**Pipeline Steps**:
1. Embed query → vector [0.1, 0.3, ...]
2. Retrieve 10 chunks from ChromaDB
3. Filter to 5 chunks with score > 0.7
4. Deduplicate (9 unique chunks remain)
5. Trim to top 5 by score
6. Format context with source attribution
7. Build prompt:
   - System: "You are an AI assistant..."
   - Context: "[1] From doc1.pdf: ...\n[2] From doc2.pdf: ..."
   - User: "Based on the context above, what are the main benefits mentioned?"
8. Call LLM, get response
9. Parse citations in response
10. Store as message with sources
11. Return to user

**Expected Response**:
"Based on the documents, the main benefits mentioned are:
1. Cost savings of 30% [doc1.pdf]
2. Improved efficiency [doc2.pdf]
3. Better user experience [doc1.pdf]"

## Common Issues to Address

- Handle very long documents (split context if needed)
- Manage token limits across different LLM providers
- Deal with poor-quality embeddings/chunks
- Handle queries that need multiple documents
- Preserve context across conversation turns
- Balance between context length and relevance
- Avoid hallucinations outside provided context
- Ensure citations are accurate and verifiable
- Handle special characters in queries/documents
- Manage performance with large document collections

## Notes for AI Assistant

- Prioritize context quality over quantity
- Implement robust deduplication logic
- Use proper prompt engineering techniques
- Make system extensible (easy to add new features)
- Log extensively for debugging RAG issues
- Handle async operations properly
- Use type hints throughout
- Document complex logic with comments
- Make retrieval parameters easily tunable
- Keep prompts in separate module for easy editing
- Test with various document types
- Optimize for low latency
- Consider token costs in design decisions
- Make it easy to add new LLM providers
- Plan for future improvements (reranking, query expansion)
- Ensure thread safety for concurrent requests
- Handle edge cases gracefully (empty docs, corrupted chunks)
- Make error messages helpful for debugging
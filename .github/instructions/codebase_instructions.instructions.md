---
applyTo: '**'
---

# Codebase Instructions

Provide project context and coding guidelines that AI should follow when generating code, answering questions, or reviewing changes.

---


## 📦 Package Management & Dependencies

- **Never manually specify or hardcode package versions** in any configuration file (`package.json`, `requirements.txt`, `pyproject.toml`, etc.).
- Always **install and set up packages using the latest stable version** available at the time of installation.
- If a version is required for compatibility reasons, confirm or infer it automatically using the project’s build system or dependency resolver—not by manual entry.
- Avoid committing lockfiles unless explicitly required by the project policy.

---

## 🔄 MCP Server Integration

- Use **MCP server `context7`** to fetch or infer the **latest and most relevant context** about any packages, frameworks, or APIs.
- When reasoning about framework-specific or library-specific setup, **defer to context7** for the most accurate, up-to-date information.
- If MCP context is unavailable or ambiguous, use generic best practices and add TODO notes suggesting validation via context7.

---

## ⚙️ Example Practices

- ✅ Use: `pip install fastapi` → installs latest version.
- ❌ Avoid: `pip install fastapi==0.110.1`
- ✅ Use MCP context7 query to check for latest FastAPI best practices before scaffolding routes or middleware.

---


# Phase 2: Frontend Foundation

## Objective
Build the React frontend foundation with Redux Toolkit, RTK Query, authentication UI, and routing. Create a solid base for the RAG application with proper state management and a component library.

## Context
You have a working backend with authentication APIs. Now build the frontend that connects to these APIs, manages authentication state, and provides a clean UI foundation for future features.

## Requirements

### State Management
- Redux Toolkit for global state
- RTK Query for API calls and caching
- Persist auth token across page refreshes
- Type-safe state access throughout app

### Authentication Flow
- Login and registration forms
- Protected routes that redirect to login
- Token storage and automatic injection in API calls
- Logout functionality
- Current user info display

### UI Requirements
- Responsive design (mobile-first)
- Clean, modern aesthetic using Tailwind
- Reusable component library
- Loading and error states
- Form validation with helpful messages

## Directory Structure to Complete

```
apps/frontend/src/
├── app/
│   ├── App.tsx                    # Main app component
│   ├── router.tsx                 # Route configuration
│   └── store.ts                   # Redux store setup
│
├── features/
│   └── auth/
│       ├── components/
│       │   ├── LoginForm.tsx
│       │   ├── RegisterForm.tsx
│       │   ├── ProtectedRoute.tsx
│       │   └── UserMenu.tsx
│       ├── hooks/
│       │   └── useAuth.ts
│       ├── authApi.ts             # RTK Query API slice
│       ├── authSlice.ts           # Redux slice for auth state
│       └── types.ts               # TypeScript types
│
├── shared/
│   ├── components/
│   │   ├── ui/
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Card.tsx
│   │   │   ├── Alert.tsx
│   │   │   ├── Spinner.tsx
│   │   │   └── Layout.tsx
│   │   └── ErrorBoundary.tsx
│   ├── hooks/
│   │   ├── useDebounce.ts
│   │   └── useLocalStorage.ts
│   ├── lib/
│   │   ├── api.ts                # Base API configuration
│   │   └── utils.ts              # Utility functions
│   └── types/
│       ├── index.ts              # Shared types
│       └── api.ts                # API response types
│
├── pages/
│   ├── LoginPage.tsx
│   ├── RegisterPage.tsx
│   ├── DashboardPage.tsx (placeholder)
│   └── NotFoundPage.tsx
│
├── assets/
│   └── (any images or static assets)
│
├── main.tsx                      # Entry point
├── index.css                     # Global styles with Tailwind
└── vite-env.d.ts                 # Vite type definitions
```

## Tasks

### 1. Redux Store Setup (app/store.ts)

Configure Redux store with:
- All RTK Query API reducers (authApi initially)
- Redux slices (auth slice initially)
- Middleware including RTK Query middleware
- Redux DevTools enabled in development
- Type exports for RootState and AppDispatch

Create typed hooks:
- `useAppDispatch`: Typed version of useDispatch
- `useAppSelector`: Typed version of useSelector

### 2. Base API Configuration (shared/lib/api.ts)

Create base configuration for RTK Query:
- Base URL from environment variable (VITE_API_BASE_URL)
- Base query using fetchBaseQuery
- Prepare headers function that:
  - Injects Authorization bearer token from auth state
  - Sets Content-Type header
- Error handling for common HTTP status codes
- Type definitions for API error responses

### 3. Auth Types (features/auth/types.ts)

Define TypeScript interfaces:
- `User`: id, email, full_name, is_active, created_at
- `LoginRequest`: email, password
- `RegisterRequest`: email, password, full_name (optional)
- `AuthResponse`: access_token, token_type
- `AuthState`: user (User or null), token (string or null), isLoading, error

### 4. Auth API Slice (features/auth/authApi.ts)

Create RTK Query API slice with endpoints:

**login**:
- Mutation endpoint
- Accepts LoginRequest
- Returns AuthResponse
- Tags: none (doesn't cache)

**register**:
- Mutation endpoint
- Accepts RegisterRequest
- Returns User
- Tags: none

**getCurrentUser**:
- Query endpoint
- No parameters (uses token from state)
- Returns User
- Provides tag: ['CurrentUser']
- Only runs if token exists

Configure:
- reducerPath: 'authApi'
- baseQuery from shared api configuration
- tagTypes: ['CurrentUser']

Export auto-generated hooks:
- useLoginMutation
- useRegisterMutation
- useGetCurrentUserQuery

### 5. Auth Redux Slice (features/auth/authSlice.ts)

Create slice with:

**Initial State**:
- token: loaded from localStorage or null
- user: null
- isAuthenticated: boolean based on token existence

**Reducers**:
- `setCredentials`: Accepts {token, user}, updates state, saves token to localStorage
- `logout`: Clears token and user, removes from localStorage
- `updateUser`: Updates user info without changing token

**Extra Reducers** (listen to RTK Query):
- On login fulfilled: automatically call setCredentials
- On getCurrentUser fulfilled: update user in state

Export actions and reducer

### 6. Auth Hook (features/auth/hooks/useAuth.ts)

Create custom hook that provides:
- Current auth state (user, token, isAuthenticated)
- Login function (wraps mutation)
- Register function (wraps mutation)
- Logout function (clears state and invalidates queries)
- Loading and error states
- Type-safe return value

This hook abstracts auth complexity from components

### 7. Shared UI Components (shared/components/ui/)

Create reusable components with Tailwind styling:

**Button.tsx**:
- Variants: primary, secondary, danger, ghost
- Sizes: sm, md, lg
- Props: onClick, disabled, loading, children, type, className
- Loading state shows spinner
- Disabled state with opacity
- Full accessibility (ARIA labels, keyboard support)

**Input.tsx**:
- Props: type, value, onChange, placeholder, label, error, disabled, required
- Label positioning above input
- Error message display below
- Focus states with ring
- Icons support (optional left/right icons)
- Password toggle for password inputs

**Card.tsx**:
- Container component with shadow and padding
- Props: children, title (optional), footer (optional), className
- Variants: default, outlined

**Alert.tsx**:
- Variants: success, error, warning, info
- Props: message, variant, onClose (optional)
- Icon for each variant
- Dismissible with close button

**Spinner.tsx**:
- Loading indicator
- Sizes: sm, md, lg
- Colors matching theme
- Centered option

**Layout.tsx**:
- Main layout wrapper
- Props: children, header, sidebar (optional)
- Responsive layout with proper spacing
- Sticky header support

All components should:
- Use TypeScript with proper prop types
- Accept className for styling override
- Use forwardRef where appropriate
- Have consistent spacing and sizing

### 8. Login Form (features/auth/components/LoginForm.tsx)

Create login form component with:
- Email input with validation (required, email format)
- Password input with validation (required)
- Remember me checkbox (optional)
- Submit button with loading state
- Error display from API
- Link to registration page
- Form validation before submission
- Handle Enter key for submission

Use useAuth hook for login logic

Display success/error messages appropriately

### 9. Register Form (features/auth/components/RegisterForm.tsx)

Create registration form with:
- Email input with validation
- Password input with strength indicator
- Confirm password input with matching validation
- Full name input (optional)
- Submit button with loading state
- Error display from API
- Link to login page
- Terms acceptance checkbox
- Client-side validation:
  - Email format
  - Password minimum length (8 chars)
  - Password confirmation matches
  - All required fields filled

Use useAuth hook for register logic

Show success message and redirect to login or auto-login

### 10. Protected Route (features/auth/components/ProtectedRoute.tsx)

Create route wrapper component that:
- Checks authentication state from Redux
- If authenticated, renders children
- If not authenticated, redirects to login page
- Preserves intended destination in URL (return URL)
- Shows loading spinner while checking auth
- Handles token validation errors

Use React Router's Navigate for redirects

### 11. User Menu (features/auth/components/UserMenu.tsx)

Create user menu component with:
- User avatar or initials
- Dropdown menu on click
- Menu items:
  - User name and email display
  - Profile link (placeholder)
  - Settings link (placeholder)
  - Logout button
- Click outside to close
- Keyboard navigation support
- Positioned properly (top-right typically)

Use useAuth hook for user data and logout function

### 12. Pages

**LoginPage.tsx**:
- Centered layout
- LoginForm component
- App branding/logo
- Link to register page
- Redirect to dashboard if already authenticated

**RegisterPage.tsx**:
- Centered layout
- RegisterForm component
- App branding/logo
- Link to login page
- Redirect to dashboard if already authenticated

**DashboardPage.tsx** (placeholder):
- Protected route
- Header with UserMenu
- Welcome message with user name
- Empty state: "Create your first project"
- Layout structure for future content

**NotFoundPage.tsx**:
- 404 message
- Link back to dashboard or home
- Simple, clean design

### 13. Router Configuration (app/router.tsx)

Set up React Router with:
- BrowserRouter
- Routes:
  - `/` - Redirects to /dashboard or /login based on auth
  - `/login` - LoginPage (public)
  - `/register` - RegisterPage (public)
  - `/dashboard` - DashboardPage (protected)
  - `*` - NotFoundPage

Use ProtectedRoute wrapper for protected routes

Implement route transitions (optional fade effect)

### 14. Main App Component (app/App.tsx)

Update App component to:
- Wrap with Redux Provider
- Include Router
- Add ErrorBoundary at top level
- Include any global providers
- Set up toast notifications (optional but recommended)
- Apply base theme/styling

### 15. Entry Point (main.tsx)

Update to:
- Import store and Provider
- Import global CSS
- Render App wrapped in StrictMode
- Add any performance monitoring (optional)

### 16. Global Styles (index.css)

Configure with:
- Tailwind directives (@tailwind base, components, utilities)
- Custom CSS variables for theme colors
- Base typography styles
- Smooth scrolling
- Focus visible styles for accessibility
- Custom utility classes for common patterns

### 17. Utility Functions (shared/lib/utils.ts)

Create helper functions:
- `cn`: Merge className strings (use clsx or custom)
- `formatDate`: Format ISO dates to readable format
- `truncate`: Truncate long strings
- `getInitials`: Get initials from name for avatar
- `validateEmail`: Email validation regex
- `validatePassword`: Password strength checker

### 18. Custom Hooks (shared/hooks/)

**useDebounce.ts**:
- Debounce any value with configurable delay
- Useful for search inputs

**useLocalStorage.ts**:
- Sync state with localStorage
- Type-safe
- Handle JSON serialization

### 19. Error Boundary (shared/components/ErrorBoundary.tsx)

Create error boundary component that:
- Catches rendering errors
- Displays fallback UI
- Logs errors to console (or monitoring service later)
- Provides reset functionality
- Shows helpful error message

### 20. Environment Variables

Update .env file with:
```
VITE_API_BASE_URL=http://localhost:8000
```

Create .env.example with comments explaining each variable

## Validation Checklist

After completing this phase, verify:

Store and API:
- [ ] Redux DevTools show auth state
- [ ] Can see API calls in Network tab
- [ ] Token persists after page refresh
- [ ] Token automatically included in authenticated requests

Authentication Flow:
- [ ] Can register new user from UI
- [ ] Registration validates inputs (email format, password length)
- [ ] Registration shows loading state during submission
- [ ] Registration shows errors from backend
- [ ] After registration, can login with created credentials
- [ ] Login validates inputs
- [ ] Login shows loading state
- [ ] Login shows errors for invalid credentials
- [ ] Successful login redirects to dashboard
- [ ] Dashboard shows current user name
- [ ] Can logout and returns to login page
- [ ] After logout, cannot access protected routes
- [ ] Accessing protected route while logged out redirects to login
- [ ] After login, redirects back to originally requested protected route

UI Components:
- [ ] All buttons have consistent styling
- [ ] Inputs show validation errors
- [ ] Forms are keyboard accessible
- [ ] Loading spinners appear during async operations
- [ ] Alerts can be dismissed
- [ ] Layout is responsive (test on mobile size)

Routes:
- [ ] All routes work
- [ ] 404 page shows for unknown routes
- [ ] Browser back/forward buttons work correctly
- [ ] URL changes reflect current page

Code Quality:
- [ ] No TypeScript errors
- [ ] No linting errors
- [ ] No console errors in browser
- [ ] Proper type inference in IDE

## Expected User Flow

1. User visits http://localhost:5173
2. Not authenticated, redirected to /login
3. Clicks "Register" link
4. Fills registration form
5. Submits, sees success message
6. Redirected to login or auto-logged in
7. Lands on dashboard
8. Sees welcome message with their name
9. User menu in header shows user info
10. Can logout from menu
11. After logout, back to login page

## Common Issues to Address

- Handle race conditions (multiple login attempts)
- Clear error messages when retrying after error
- Prevent form submission while loading
- Handle network errors gracefully
- Show appropriate loading states everywhere
- Ensure consistent spacing and alignment
- Mobile responsive at all viewport sizes
- Keyboard navigation works throughout
- Forms reset after successful submission
- Password visibility toggle works
- Protected routes checked on mount and route change

## Notes for AI Assistant

- Use functional components with hooks exclusively
- Type all props interfaces explicitly
- Use React.FC or explicit return types for clarity
- Leverage RTK Query's automatic caching
- Don't fetch current user on every route change (cache it)
- Use controlled components for all forms
- Implement proper form validation (client-side)
- Handle both optimistic and pessimistic UI updates
- Keep components focused and single-responsibility
- Extract reusable logic into custom hooks
- Use semantic HTML elements
- Ensure WCAG accessibility standards
- Test keyboard navigation
- Use environment variables for all config
- Add prop validation for all components
- Document complex components with JSDoc
- Use CSS-in-JS or Tailwind consistently (prefer Tailwind)
- Implement error boundaries at appropriate levels
- Handle loading states explicitly (no flash of content)
- Use proper HTTP status code handling
# Canonical Task Fields

These are the standardised field names used across all output format adapters. They match the task template defined in `skills/technical-planning/references/task-design.md`.

Every format's `authoring.md` must map these fields to its storage mechanism. Consumers (implementation, review) expect these names in task content.

## Fields

### Problem (required)

Why this task exists — what issue or gap it addresses. One sentence minimum.

### Solution (required)

What we're building — the high-level approach. One sentence minimum.

### Outcome (required)

What success looks like — the verifiable end state. One sentence minimum.

### Do (required)

Specific implementation steps. At least one concrete action.

Format: bullet list.

```markdown
**Do**:
- Create `src/services/auth.ts` with `validateToken()` method
- Add middleware to `src/middleware/index.ts`
- Wire up in `src/routes/api.ts`
```

### Acceptance Criteria (required)

Pass/fail criteria as a checkbox list. At least one criterion.

```markdown
**Acceptance Criteria**:
- [ ] Token validation returns true for valid tokens
- [ ] Expired tokens are rejected with 401
- [ ] Missing tokens return 401
```

### Tests (required)

Named test cases as backtick-quoted strings. At least one test. Include edge cases, not just happy path.

```markdown
**Tests**:
- `"it validates a correctly signed token"`
- `"it rejects an expired token"`
- `"it returns 401 when no token is provided"`
```

### Edge Cases (when relevant)

Boundary conditions and unusual inputs specific to this task.

```markdown
**Edge Cases**:
- Token with future `nbf` (not-before) claim
- Token signed with rotated key
```

### Context (when relevant)

Relevant specification decisions, code examples, or constraints pulled forward for the implementer. Use blockquote format.

```markdown
**Context**:
> From spec: "Use RS256 for token signing. Key rotation happens weekly."
> See `docs/workflow/specification/auth.md` section 3.2 for the full token schema.
```

### Spec Reference (required)

Path to the specification for ambiguity resolution.

```markdown
**Spec Reference**: `docs/workflow/specification/{topic}.md`
```

### Needs Clarification (when flagged)

Open questions that need answering before implementation. Only present when the task has been flagged as `[needs-info]`.

```markdown
**Needs Clarification**:
- What's the rate limit threshold?
- Per-user or per-IP?
```

## Summary Table

| Field | Required | Format |
|-------|----------|--------|
| Problem | Yes | Prose |
| Solution | Yes | Prose |
| Outcome | Yes | Prose |
| Do | Yes | Bullet list |
| Acceptance Criteria | Yes | Checkbox list |
| Tests | Yes | Backtick-quoted list |
| Edge Cases | When relevant | Bullet list or prose |
| Context | When relevant | Blockquote |
| Spec Reference | Yes | Inline code path |
| Needs Clarification | When flagged | Bullet list |

## Full Example

```markdown
### Task auth-1-2: Validate JWT tokens

**Problem**: API endpoints accept any request — there's no token validation, so unauthenticated users can access protected resources.

**Solution**: Add JWT validation middleware that checks token signature, expiry, and required claims before allowing access to protected routes.

**Outcome**: Protected API endpoints reject invalid/missing tokens with 401, and pass validated user context to route handlers.

**Do**:
- Create `src/middleware/auth.ts` with `validateToken()` middleware
- Validate signature using RS256 public key from `config/keys/`
- Check `exp` and `nbf` claims
- Extract `userId` and `roles` into `req.user`
- Apply middleware to routes in `src/routes/api.ts`

**Acceptance Criteria**:
- [ ] Valid token passes validation and populates `req.user`
- [ ] Expired token returns 401
- [ ] Missing token returns 401
- [ ] Invalid signature returns 401

**Tests**:
- `"it passes a valid token and populates req.user"`
- `"it rejects an expired token with 401"`
- `"it rejects a missing token with 401"`
- `"it rejects a token with invalid signature"`

**Edge Cases**:
- Token with future `nbf` claim should be rejected
- Token signed with a rotated (old) key — depends on key rotation policy

**Context**:
> From spec: "Use RS256 for all token signing. Public keys are stored in `config/keys/`."

**Spec Reference**: `docs/workflow/specification/authentication.md`
```

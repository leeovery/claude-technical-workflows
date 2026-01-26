---
status: concluded
date: 2026-01-20
---

# Authentication Flow Discussion

## Context
Discussed the authentication approach for the application, including OAuth2 integration, session management, and token refresh strategies.

## Decisions
- Use OAuth2 with PKCE flow for public clients
- JWT tokens with 15-minute expiry
- Refresh tokens stored in httpOnly cookies
- Session invalidation via token blacklist in Redis

## Edge Cases
- Token refresh during concurrent requests: queue and retry
- Cross-tab session sync: use BroadcastChannel API
- Offline scenarios: cache last valid session, re-auth on reconnect

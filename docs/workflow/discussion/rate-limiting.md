---
status: in-progress
date: 2026-01-25
---

# Rate Limiting Discussion

## Context
Exploring rate limiting strategies for the API.

## Notes
- Considering sliding window vs token bucket
- Need to discuss per-user vs per-endpoint limits
- Redis-based distributed rate limiting

## Open Questions
- What are the default limits per tier?
- How to handle burst traffic during launches?

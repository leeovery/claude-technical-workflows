# Topic-Level Management

Status: brainstorming
Date: 2026-03-15
Depends on: [Cross-Cutting Work Type](cross-cutting-work-type.md) (but not required for its initial build)

## Problem

Currently there's no way to manage individual topics after the fact. Work unit lifecycle management exists (complete, cancel, reactivate, pivot), but once a spec is completed and classified, there's no mechanism to change that classification or move it between work units.

This matters because decisions made at spec completion aren't always final — a user might realise during planning or implementation that a feature spec should actually be cross-cutting, or that a promoted cross-cutting spec was a mistake.

## Proposal

A topic-level management capability for after-the-fact changes to spec classification and location.

### Actions

**Reclassify: feature → cross-cutting**

User realises an epic feature spec should actually be cross-cutting. Reclassifying triggers auto-promotion (same mechanics as if it had been classified correctly at spec completion): creates a cross-cutting work unit, moves discussion + spec, records provenance, marks topic as promoted in the epic.

**Reclassify: cross-cutting → feature**

A directly-created cross-cutting work unit turns out to be a buildable feature. Would need to become a feature work unit (or be absorbed into an epic). Mechanics TBD — less common scenario.

**Recall: undo a promotion**

A spec was promoted from an epic to a cross-cutting work unit, but the user wants to reverse it. Provenance tracking enables this — the system knows where it came from and can move it back. The cross-cutting work unit would be removed or marked cancelled.

### Access Point

How users reach topic-level management is TBD. Candidates:
- Option within `continue-epic` when viewing topics
- Dedicated command (e.g., `/manage-topic`)
- Part of the existing work unit manage menu, extended to topic level

### Scope Notes

- This is an enhancement, not a prerequisite for the cross-cutting work type. The initial build can ship without it — users can work around it by manually restructuring if needed
- The most common path (correct classification at spec completion) doesn't need this. It's a safety net for when the initial assessment was wrong
- Keeping the action set small: reclassify and recall cover the realistic scenarios

## Open Questions

### 1. Recall mechanics

When recalling a promoted spec back into an epic:
- Does the cross-cutting work unit get deleted or marked cancelled?
- Does the provenance record get updated or removed?
- What if the cross-cutting spec was already referenced by other plans?

### 2. Cross-cutting → feature reclassification

Less common but possible. What does the work unit become? Options:
- Convert in place (change work_type in project manifest, add planning/implementation phases)
- Create a new feature work unit and move content (similar to promotion but in reverse)

### 3. UX for access

Where does this live? Needs to feel natural without cluttering existing menus.

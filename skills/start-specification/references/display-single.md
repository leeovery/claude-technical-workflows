# Display: Single Discussion

*Reference for **[start-specification](../SKILL.md)***

---

Auto-proceed path — only one concluded discussion exists, so no selection menu is needed.

Convert discussion filename to title case (`auth-flow` → `Auth Flow`).

## Route by Spec Coverage

#### If has_individual_spec is true

→ Load **[display-single-has-spec.md](display-single-has-spec.md)** and follow its instructions.

#### If any spec in the specifications array lists this discussion in its sources

→ Load **[display-single-grouped.md](display-single-grouped.md)** and follow its instructions.

#### Otherwise

→ Load **[display-single-no-spec.md](display-single-no-spec.md)** and follow its instructions.

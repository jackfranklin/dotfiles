---
name: glossary
description: Glossary: capture stable, repository-wide terms and concepts in `.jai/glossary.md` when they emerge. Use when a term or concept should become canonical repository context.
---

Maintain the repository glossary at `.jai/glossary.md`. When invoked without a named term, review the current conversation and relevant repository context for glossary candidates.

1. Read `.jai/glossary.md` if it exists. Preserve its terminology and structure; update an existing entry rather than duplicating it.
2. Add only canonical repository knowledge: stable, broadly useful definitions of domain terms, entities, architecture concepts, or invariants. Write concise definitions in the repository's own terms.
3. Do not add plan decisions, session outcomes, open questions, temporary implementation details, or information that is readily derived from the code.
4. If it is unclear whether a candidate is canonical enough to store, ask the user before writing it: “Should I add `<term>` to the repository glossary?” Do not create or change the file until they confirm.
5. Otherwise, create `.jai/glossary.md` if needed and add or update the entry under a clear glossary heading.

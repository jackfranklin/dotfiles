---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

**Knowledge Persistence (.jai/grill-docs.md):**
1.  **Read Context:** At the start of the session, check if `.jai/grill-docs.md` exists in the current repository. If it does, read it and use it as context for the discussion.
2.  **Extract Knowledge:** As we talk, identify information that is useful broadly across the repository (e.g., terminology, definitions of entities, architecture concepts) rather than specific to the current task.
3.  **Persist Knowledge:** Save this extracted knowledge into `.jai/grill-docs.md`. If the file does not exist, create it. Maintain a clean, structured format (e.g., glossary, concepts).

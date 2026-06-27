---
name: summarize-conversation
description: Use when the user requests a summary of the current conversation, or when the conversation context is full and needs to be summarized before clearing.
---

# Summarize Conversation

## Overview
Summarizes the active conversation into a succinct, structured markdown format.

## When to Use
- When the user asks to summarize the conversation.
- When the conversation context window is filling up, and the user wants to preserve key context before starting a fresh conversation session.

## Core Pattern
1. Analyze the conversation history (including recent queries, actions, and the transcript) to identify:
   - **Goal/Context**: What was the primary objective of this session?
   - **Completed Tasks**: What tasks, changes, or files were successfully implemented or analyzed?
   - **Open items / Next steps**: What was left incomplete or needs to be addressed in the next session?
   - **Key decisions & technical context**: Any constraints, patterns discovered, or design choices made.
   - **Key files**: List of main files modified, created, or read.
2. Present a succinct markdown-formatted summary directly in the chat response. Write from the agent's perspective — use "you" for the user and "I" for yourself throughout all sections (e.g. "you asked me to...", "I implemented...", "you decided...").
3. Keep the summary under 150-200 words, using bullet points for readability.
4. Avoid conversational filler or meta-commentary. Just print the markdown block.

## Common Mistakes
- Writing an overly verbose narrative instead of a crisp bulleted summary.
- Including trivial details like git commands or minor syntax updates.
- Forgetting to explicitly list the next steps.

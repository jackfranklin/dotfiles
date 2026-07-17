# Glossary

## Persistent skill output

Plans, handoffs, and backlog items that skills preserve beyond the current conversation. In a repository with a GitHub remote, these are stored as GitHub Issues rather than in a central store or `.jai/` files.

## Plan

A detailed implementation plan stored in a GitHub Issue whose title starts with `[PLAN]`.

## Handoff

A record of in-progress work and conversation state for a future session or engineer, stored in a GitHub Issue whose title starts with `[HANDOFF]`.

## Backlog item

A future task captured by the `later` skill as a normal GitHub Issue, without a title prefix.

## Legacy `.jai/` files

Older local persistence files no longer used by the plan, handoff, or `later` skills. Those skills use GitHub Issues exclusively.

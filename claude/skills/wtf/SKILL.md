---
name: wtf
description: Re-pitch the preceding response in clear, shared language.
disable-model-invocation: true
---

# WTF

The previous response did not land. Re-pitch it.

1. If the earlier response may have answered the wrong question, start with **What I think you mean**. In one sentence, state the request or point that you are about to explain. This lets the user correct the premise.
2. Give the minimum context needed to understand the point.
3. State the point again in ASD-STE100 Simplified Technical English: use short sentences, common words, active voice, and one instruction or idea per sentence.
4. Use the conversation's **working terms**. Reuse exact names for concepts, entities, decisions, requirements, and identifiers that the user has introduced, defined, repeated, or corrected. Do not rename them or introduce a synonym.
5. If a term is new or can have two meanings, define it before using it. If the conversation does not establish a working term, use ordinary, precise language.
6. End with the next action, decision, or question, if there is one.

Use this shape when you include the interpretation:

```markdown
## What I think you mean

## Context

## The point

## Next step
```

Do not defend the earlier wording. Do not merely shorten it. Explain the idea so the user can follow it from this point.

When asked to present a plan for review, or when the user says "review this
plan", or when you want the user to annotate a plan before you proceed:

1. Write the plan to a temporary file:
   ```
   /tmp/plan-review-<timestamp>.md
   ```
2. Run the tool and capture its stdout:
   ```
   node /home/jack/git/ai-plan-reviewer/dist/cli.js /tmp/plan-review-<timestamp>.md
   ```
   The CLI will open the browser. Block until it exits (the user clicking "Done"
   causes it to exit).

3. If stdout is empty (user had no comments), say:
   "The plan looks good to you — no comments. Proceeding."

4. If stdout contains annotated output, say:
   "Here is what you commented:" and display the **Comment Summary** table from
   the output.

5. Revise the plan, addressing each comment. For each change, note which comment
   it addresses and what you changed.

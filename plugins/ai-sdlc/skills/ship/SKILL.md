---
name: ship
description: Finish an issue - run the verifier, make sure the Definition of Done is met, mark the pull request ready and review it. Use when the work on an issue's branch seems complete, or the user runs /ship.
---

# Ship an issue

1. **Verify.** Run the `verifier` agent. If anything fails, fix it and verify again. Do not continue on your own judgement.
2. **Check the Definition of Done** (WORKFLOW.md section 7) item by item. No scenario for this issue may still be tagged `@wip`.
3. **Update the pull request** body from the template: what changed and why, `Closes #<n>`, scenarios added or turned green, measurements if relevant, the checklist ticked honestly, and a copy of the accepted Plan. Push.
4. **Mark it ready:** `gh pr ready`.
5. **Review it yourself** against the project's `REVIEW.md` if present (bugs, security, spec and plan compliance, DDD, hexagonal and CQS rules), fix what you find, and comment on anything left for the owner.
6. **Hand over:** tell the owner it's ready to merge. Never merge it yourself.

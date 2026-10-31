---
name: handoff
description: Record progress on the current issue as a Handoff comment so the next session can continue. Use before stopping work mid-way, at the end of a session, or when the user runs /handoff.
---

# Write a handoff

1. **Find the issue** from the branch name (`feat/<n>-…`); ask if unclear.
2. **Save the work:** commit what's in progress (WIP is fine on the issue's branch) and push.
3. **Post the comment** in the format of WORKFLOW.md section 6 (Done, Scenarios, Next, Blocked or decisions needed, How to check) with `gh issue comment <n> --body-file <file>`. Make Next specific enough to start without re-reading the code.
4. **Tick** any "Done when" or Definition of Done items now met in the issue body, and say which.

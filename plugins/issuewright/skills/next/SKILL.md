---
name: next
description: Pick the next issue to work on from the current sprint and load its context. Use at the start of a session, when the user asks what's next, or runs /next.
---

# Pick the next issue

1. **List candidates:** open issues in this repository in the current iteration (sprint), not assigned to someone else: `gh issue list --state open --json number,title,labels,milestone,assignees`. If the project board is reachable, prefer its Sprint backlog and In progress items.
2. **Order:** something already In progress on this computer (a local branch) first; then earliest milestone; `priority: must-have` before `should-have` before `nice-to-have`; then sub-issues in their parent's slice order; then lowest number. Skip `blocked`.
3. **Load it:** `gh issue view <n> --comments`, its parent's spec if it's a sub-issue, and the latest Handoff comment.
4. **Report** in a few lines: the issue, why it's next, its gate state, the last handoff's Next list, and the next action: `/plan` if no accepted plan, otherwise continue building on its branch.

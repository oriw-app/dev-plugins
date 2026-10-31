---
name: intent
description: Turn a rough idea, request or finding into the Intent section of a GitHub issue (stage 1, Plan). Use when the user describes something new to build or change, or runs /intent.
---

# Write an intent

1. **Find or create the issue.** If the user names an issue, read it with `gh issue view <n> --comments`. Otherwise create one with the Intent template's title format, label `feature` (or `bug`, `chore`, `spike`), and status Inbox.
2. **Ask before writing**, in one short round: who is it for, what problem they have today, what must be true when it's done, constraints (privacy, speed, platforms, dates), and how we'll know it worked. Skip questions the issue or conversation already answers.
3. **Write the Intent section** into the issue body exactly in the format of WORKFLOW.md section 6, using the project's glossary words (`domainDoc` in `.claude/issuewright.json`). Keep it short; list unknowns under Open questions rather than guessing.
4. **Update with** `gh issue edit <n> --body-file <file>`, keeping any other sections.
5. **Hand over to the owner:** say the intent is ready and that the owner adds `intent: accepted` (or comments with changes). Never add that label yourself.

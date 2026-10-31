---
name: sprint-review
description: Write the end-of-sprint report and run the retro, turning lessons into changes to CLAUDE.md, skills or hooks. Use at the end of a sprint or when the user runs /sprint-review.
---

# Sprint review and retro

1. **Report** on the Sprint issue: pull requests merged, scenarios that went from `@wip` to passing, measurements, open risks, and how to try the build.
2. **Retro:** ask the owner three questions: what worked, what didn't, what to change.
3. **Turn answers into pull requests:** a mistake Claude repeated → a line under "Things Claude gets wrong" in `CLAUDE.md`; a rule that keeps being missed → a skill change in the dev-plugins repository; a rule that must never be broken → a hook. Link them on the Sprint issue, then close it.

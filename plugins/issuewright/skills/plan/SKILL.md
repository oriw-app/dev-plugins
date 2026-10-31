---
name: plan
description: Write the implementation Plan section on a GitHub issue that is being started (stage 3, Build) - files that change, order of work with tests first, risks and proof - using Claude Code plan mode. Use when starting work on a Ready issue, after /next, or when the user runs /plan.
---

# Write a plan

1. **Check the gates.** The issue (or its parent, for a sub-issue) must have `spec: accepted`; chores need none. Read the issue, its parent's spec if any, the latest handoff, and the code it touches.
2. **Plan in plan mode** (read-only). Produce the Plan section exactly as in WORKFLOW.md section 6:
   - **Files that change**, grouped by layer: domain, application, adapters, composition root, features, docs.
   - **Order of work**, TDD and core first: scenarios (if not on the branch yet) → failing unit test → core code → refactor, rule by rule → adapters with their own tests → wiring → scenarios pass.
   - **Risks:** what could break, the riskiest step, alternatives rejected.
   - **Proof:** the scenarios and tests that must pass, and measurements if speed, size or start-up change.
3. **Interrogate it** before posting: could someone who hasn't seen this conversation build it from the plan alone? Is anything CQS- or hexagonal-unsafe?
4. **Post it** into the issue body (`gh issue edit <n> --body-file`) and create the branch from the main branch: `git switch -c feat/<n>-<slug> origin/<main>` (or `fix/`, `chore/`…). Push it and open a **draft** pull request: `gh pr create --draft --title "<issue title>" --body "Closes #<n>"`.
5. **Hand over:** the owner adds `plan: accepted` or comments. Hooks block code edits until then; docs and scenario files are allowed.

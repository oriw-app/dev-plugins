---
name: ai-sdlc
description: The development workflow for this project. Use for any work on GitHub issues, branches, pull requests, planning, releases or code changes in a repository that uses the ai-sdlc plugin. Covers the issue lifecycle and owner gates, vertical-slice sub-issues, GitHub Flow, and DDD + BDD + TDD with hexagonal architecture and CQS.
---

# AI-native SDLC: how work is done here

The full guide, with flowcharts, is [WORKFLOW.md](WORKFLOW.md) in this skill's folder. Read the section you need before acting; when in doubt, read sections 1, 5 and 9.

## Rules that always apply

1. **The GitHub issue is the spec.** Before any work, read the issue (body and latest comments) with `gh issue view <n> --comments`. Write intent, spec and plan into the issue body; write progress and handoffs as comments. Never work from memory or local notes.
2. **Owner gates.** Only the owner adds `intent: accepted`, `spec: accepted` and `plan: accepted`, merges pull requests and authorises releases. Never add these labels, merge or release yourself; ask the owner.
3. **Order of work:** intent → spec → (sub-issues) → Ready → sprint → plan → build → verify → pull request → owner merges.
4. **One branch and one pull request per issue or sub-issue**, from the main branch, named `feat|fix|chore|docs|spike/<issue>-<slug>`, saying `Closes #<issue>`. Never commit to the main branch; never force-push.
5. **Vertical slices.** Every sub-issue works end to end on its own. Never slice by layer.
6. **Words, behaviour, then code:** glossary terms first (DDD), scenarios second (BDD), failing unit test before each rule (TDD), core before adapters (hexagonal), commands return no data and queries change nothing (CQS). See the `ddd-hexagonal`, `bdd-scenarios` and `tdd` skills.
7. **Done means the Definition of Done** in WORKFLOW.md section 7, proven by the `verifier` agent, not by your own judgement.
8. **Stopping mid-way:** post a handoff comment (`/handoff`).

## Project settings

Read `.claude/sdlc.json` at the repository root if it exists. It names the main branch, source, test and docs globs, the features folder, the domain glossary (`domainDoc`), the architecture notes (`architectureDoc`) and the check commands (`quickCheck`, `fullCheck`). Read the project's `CLAUDE.md` for anything project-specific; it wins over defaults but never over the gates.

## Commands

`/intent`, `/spec`, `/plan`, `/next`, `/ship`, `/handoff`, `/bug`, `/milestone-plan`, `/sprint-plan`, `/sprint-review`, `/release`. Each is a skill in this plugin.

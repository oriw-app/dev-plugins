---
name: spec
description: Turn an accepted intent into the Spec section of its GitHub issue (stage 2, Design) - requirements, DDD domain model, hexagonal design, BDD scenarios and vertical slices - and create sub-issues when it's larger than one pull request. Use after the owner adds "intent: accepted", or when the user runs /spec.
---

# Write a spec

1. **Check the gate.** `gh issue view <n> --json labels,body,comments`. Stop and tell the user if `intent: accepted` is missing.
2. **Read the rules:** the project's glossary (`domainDoc`), architecture notes (`architectureDoc`), `CLAUDE.md`, and the `ddd-hexagonal` and `bdd-scenarios` skills.
3. **Write the Spec section** in the issue body, in the format of WORKFLOW.md section 6:
   - Requirements, numbered and testable.
   - Domain: bounded context, glossary words (new ones marked *(new)*), aggregates, commands, queries, domain events.
   - Design: ports, adapters, read models.
   - Scenarios in Gherkin, one behaviour each.
   - Flagged concerns: any conflict with privacy, security, accessibility or project rules, with a proposed resolution. Never resolve a conflict silently.
4. **Size it.** If it's more than one pull request (about a day), list **vertical slices** in build order under Slices, each usable end to end, and create one sub-issue per slice:
   - `gh issue create --title "<slice>" --body "<its scenarios and ports; Part of #<parent>>" --label feature`
   - link it: `id=$(gh api repos/{owner}/{repo}/issues/<sub> -q .id)` then `gh api -X POST repos/{owner}/{repo}/issues/<parent>/sub_issues -F sub_issue_id=$id`
   Never slice by layer.
5. **Hand over:** tell the owner the spec is ready; the owner adds `spec: accepted` or comments. Never add the label yourself.

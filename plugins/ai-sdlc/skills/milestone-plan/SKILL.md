---
name: milestone-plan
description: Prepare milestone (release) planning - review the last milestone, propose the goal, scope, date, risks and refinement list for the next. Use at the start of a release cycle or when the user runs /milestone-plan. Planning only; never writes specs or plans.
---

# Milestone planning

Prepare, then let the owner decide. Read-only until the owner approves.

1. **Review the last milestone:** `gh api repos/{owner}/{repo}/milestones?state=all`; what shipped (closed issues), what slipped (open), measurements from release notes or issues.
2. **Propose the goal** in one sentence.
3. **Propose the scope:** parent and single issues from the roadmap, by priority, sized to the milestone's capacity (sprints × the owner's typical throughput from past sprints).
4. **Due date and risks:** dependencies, outside approvals, anything not yet Ready.
5. **Refinement list:** in-scope issues still needing intent or spec, in the order to refine them.
6. **After approval:** set the milestone on each issue, write the goal into the milestone description, and move issues left out to a later milestone.

---
name: bug
description: Record a bug as a GitHub issue with a failing scenario, and fix it test-first. Use when the user reports something broken or runs /bug.
---

# Report and fix a bug

1. **Reproduce** it, or ask for steps until you can.
2. **Write the issue** (label `bug`): what happened, what should happen, version and system, and the bug as a Gherkin scenario (`Given … When … Then … But …`).
3. **Plan the fix** with `/plan` on a `fix/<n>-<slug>` branch. The owner accepts the plan.
4. **Failing test first:** commit the scenario and a failing unit test that reproduces the bug. From then on the `tests-locked` hook stops that test being changed; make it pass by fixing the code.
5. **Ship** with `/ship`.

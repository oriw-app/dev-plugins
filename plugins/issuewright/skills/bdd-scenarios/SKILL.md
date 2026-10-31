---
name: bdd-scenarios
description: Writing and running BDD scenarios in Gherkin as executable specs. Use when writing a spec's Scenarios section, creating or editing .feature files, wiring step definitions, or deciding if a behaviour is done.
---

# BDD scenarios

- Scenarios come from the issue's Spec section and are committed **before code**, as `.feature` files in the bounded context's folder under the project's `featuresDir`, tagged `@wip` and `@issue-<n>`.
- One behaviour per scenario, named for the outcome ("Wrong passphrase doesn't open the vault").
- Given sets state in domain words; When is one action; Then checks what's observable. No implementation or UI details unless the scenario is about the UI.
- `Scenario Outline` with `Examples` when only data changes. About ten scenarios per file.
- Scenarios drive the **application layer** with in-memory adapters, so they're fast. End-to-end scenarios against the running app are few and reserved for key journeys.
- CI skips `@wip`. Remove `@wip` only when the scenario passes. An issue is not done while any of its scenarios is `@wip`.
- If the issue's scenarios change, update the issue first, then the feature file.

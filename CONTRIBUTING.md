# Contributing to dev-plugins

Thank you for helping. This repository uses its own **issuewright** workflow, so changes go through GitHub issues and pull requests like any project that uses it.

## How a change goes in

1. **Open an issue** describing the problem and the outcome you want (the Intent template). For a bug, include the behaviour as a scenario: Given, When, Then, But.
2. **Wait for the owner to accept it** (`intent: accepted`). Then the spec and plan are agreed on the issue. Small fixes can be accepted in one step.
3. **Branch from `main`:** `feat/<issue>-<slug>`, `fix/<issue>-<slug>`, `docs/<issue>-<slug>`.
4. **Test first.** Hook changes start with a failing case in `tests/issuewright-hooks.sh`. Skill and guide changes say in the pull request what behaviour changes and why.
5. **Run the checks:**
   ```sh
   claude plugin validate .claude-plugin/marketplace.json
   claude plugin validate plugins/issuewright --strict
   bash tests/issuewright-hooks.sh
   ```
6. **Open a pull request** with `Closes #<issue>`. CI runs the same checks. The owner reviews and merges.

## Rules for each part

| Part | Rules |
| --- | --- |
| **WORKFLOW.md** | It's the single source of truth; skills point to it rather than repeating it. Keep flowcharts in Mermaid so GitHub draws them. Plain, specific English. |
| **Skills** | One job each. `description` says when to use it, because that decides when Claude loads it. Never let a skill add gate labels, merge or release. |
| **Hooks** | Fast (well under a second, except `checks-before-done`), only active where `.claude/issuewright.json` exists, clear messages that say what to do instead. Fail open only when a required tool is missing, and say so. Every rule has a test that proves it blocks and a test that proves it allows. |
| **Agents** | The verifier never edits. Its report format is part of its contract. |
| **Versions** | Bump `version` in both `plugin.json` and `marketplace.json` for any change users will notice, and note it in the pull request. Tag releases with `claude plugin tag plugins/issuewright`. |

## Adding a new plugin

Create `plugins/<name>/` with its own `.claude-plugin/plugin.json`, add an entry to `.claude-plugin/marketplace.json`, a row to the README table, and tests under `tests/`.

## Licence

By contributing you agree that your contribution is licensed under Apache-2.0, like the rest of the repository.

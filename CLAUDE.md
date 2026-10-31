# dev-plugins: notes for Claude

A Claude Code plugin marketplace. The main plugin is `plugins/issuewright`; its complete guide is `plugins/issuewright/skills/issuewright/WORKFLOW.md`, and this repository follows it.

## Commands
```sh
claude plugin validate .claude-plugin/marketplace.json
claude plugin validate plugins/issuewright --strict
bash tests/issuewright-hooks.sh
```

## Conventions
- WORKFLOW.md is the single source; skills link to it instead of repeating it.
- Every hook rule has a blocking test and an allowing test in `tests/issuewright-hooks.sh`.
- Bump the version in `plugin.json` and `marketplace.json` together.
- Plain, specific English everywhere.

## Things Claude gets wrong
- Writing project-specific (Oriw) details into the generic plugin. Keep it generic; projects configure it with `.claude/issuewright.json`.

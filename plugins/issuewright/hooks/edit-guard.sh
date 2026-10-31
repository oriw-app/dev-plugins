#!/usr/bin/env bash
# PreToolUse on file edits: plan gate, test-first, tests-locked and secret checks.
source "$(dirname "$0")/lib.sh"

FILE="$(json '.tool_input.file_path // .tool_input.notebook_path')"
[ -z "$FILE" ] && exit 0
REL="${FILE#"$ROOT"/}"
[[ "$REL" == /* ]] && exit 0   # outside the repository

CONTENT="$(printf '%s' "$INPUT" | jq -r '[.tool_input.content, .tool_input.new_string, (.tool_input.edits // [] | .[].new_string), .tool_input.new_source] | map(select(. != null)) | join("\n")')"

# 1. No secrets, ever.
if printf '%s' "$CONTENT" | grep -Eq -- '-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{40,}|sk-ant-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{32,}|xox[abpr]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}'; then
  deny "issuewright: this looks like a key, token or password. Secrets never go in files; use the project's secret store or environment variables."
fi

# 2. Never edit on the main branch.
if [ "$BRANCH" = "$MAIN" ] || [ -z "$BRANCH" ]; then
  deny "issuewright: no edits on '$MAIN'. Start from an issue: /next picks one, /plan creates its branch."
fi

DOCS="$(cfg_list .docsGlobs '["docs/**", "*.md", "features/**"]')"
SOURCE="$(cfg_list .sourceGlobs '[]')"
TESTS="$(cfg_list .testGlobs '["tests/**", "features/**"]')"

is_docs=false; printf '%s\n' "$DOCS" | matches_any "$REL" && is_docs=true
is_test=false; printf '%s\n' "$TESTS" | matches_any "$REL" && is_test=true

# 3. Plan gate: before "plan: accepted", only docs and scenarios may change.
if ! $is_docs; then
  if [ -z "$ISSUE" ]; then
    deny "issuewright: branch '$BRANCH' isn't linked to an issue. Use feat|fix|chore|docs|spike/<issue>-<slug> so the work traces to its spec."
  fi
  if ! has_label "plan: accepted"; then
    deny "issuewright: issue #$ISSUE has no accepted plan yet, so only docs and scenarios may change. Write the plan with /plan; the owner adds 'plan: accepted'."
  fi
fi

# 4. Tests locked on fix branches: a committed failing test can't be changed to make the fix pass.
if $is_test && [[ "$BRANCH" == fix/* ]]; then
  b="$(base_ref)"
  if [ -n "$b" ] && git log --name-only --format= "$b..HEAD" 2>/dev/null | grep -Fxq "$REL"; then
    if ! has_label "test: change approved"; then
      deny "issuewright: $REL holds the committed failing test for this bug. Fix the code, not the test. If the test itself is wrong, ask the owner to add 'test: change approved' to #$ISSUE."
    fi
  fi
fi

# 5. Test first: source code changes only after a test or scenario has changed on the branch.
if [ -n "$SOURCE" ] && ! $is_test && ! $is_docs && printf '%s\n' "$SOURCE" | matches_any "$REL"; then
  if ! branch_files | while IFS= read -r f; do printf '%s\n' "$TESTS" | matches_any "$f" && echo yes && break; done | grep -q yes; then
    deny "issuewright: write the failing test or scenario first (TDD). No test or scenario has changed on this branch yet, so $REL can't be edited."
  fi
fi

exit 0

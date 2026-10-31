#!/usr/bin/env bash
# Shared helpers for ai-sdlc hooks. Hooks only act in repositories that opt in with .claude/sdlc.json.
set -uo pipefail

INPUT="$(cat)"

need() { command -v "$1" >/dev/null 2>&1; }

if ! need jq; then
  echo "ai-sdlc: jq is not installed, so workflow hooks are off. Install jq to enable them." >&2
  exit 0
fi

json() { printf '%s' "$INPUT" | jq -r "$1 // empty"; }

ROOT="$(cd "$(json .cwd)" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)" || ROOT=""
[ -z "$ROOT" ] && ROOT="${CLAUDE_PROJECT_DIR:-}"
[ -z "$ROOT" ] && exit 0
CONFIG="$ROOT/.claude/sdlc.json"
[ -f "$CONFIG" ] || exit 0   # project hasn't opted in
cd "$ROOT" || exit 0

cfg() { jq -r "$1 // empty" "$CONFIG"; }
cfg_list() { jq -r "($1 // $2)[]" "$CONFIG"; }

MAIN="$(cfg .mainBranch)"; MAIN="${MAIN:-main}"
BRANCH="$(git branch --show-current 2>/dev/null)"
ISSUE=""
if [[ "$BRANCH" =~ ^(feat|fix|chore|docs|spike)/([0-9]+)(-|$) ]]; then ISSUE="${BASH_REMATCH[2]}"; fi
GITDIR="$(git rev-parse --absolute-git-dir 2>/dev/null)"
CACHE="$GITDIR/ai-sdlc"; mkdir -p "$CACHE" 2>/dev/null

# Labels of the branch's issue, cached for 60 seconds; falls back to the last known labels when offline.
issue_labels() {
  local f="$CACHE/labels-$ISSUE" now age
  now=$(date +%s)
  if [ -f "$f" ]; then age=$(( now - $(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f") )); else age=999999; fi
  if [ "$age" -gt 60 ] && need gh; then
    gh issue view "$ISSUE" --json labels -q '.labels[].name' > "$f.tmp" 2>/dev/null && mv "$f.tmp" "$f"
    rm -f "$f.tmp"
  fi
  [ -f "$f" ] && cat "$f"
}
has_label() { issue_labels | grep -Fxq "$1"; }

# Base of the branch: where it left the main branch.
base_ref() { git merge-base HEAD "origin/$MAIN" 2>/dev/null || git merge-base HEAD "$MAIN" 2>/dev/null; }

# Files changed on this branch, committed or not.
branch_files() {
  local b; b="$(base_ref)"
  { [ -n "$b" ] && git diff --name-only "$b" HEAD; git diff --name-only HEAD; git ls-files --others --exclude-standard; } 2>/dev/null | sort -u
}

matches_any() { # path, then globs on stdin
  local p="$1" g
  while IFS= read -r g; do [ -n "$g" ] && [[ "$p" == $g ]] && return 0; done
  return 1
}

deny() {
  jq -n --arg r "$1" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
  exit 0
}

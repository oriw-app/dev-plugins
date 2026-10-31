#!/usr/bin/env bash
# SessionStart: put the branch's issue (the spec) into Claude's context.
source "$(dirname "$0")/lib.sh"

if [ -z "$ISSUE" ]; then
  echo "ai-sdlc: on branch '${BRANCH:-?}', which isn't an issue branch. Use /next to pick work from the sprint, or /intent for something new. Code can only change on an issue branch with an accepted plan."
  exit 0
fi
if ! need gh; then echo "ai-sdlc: on issue #$ISSUE, but the GitHub CLI (gh) isn't installed; read the issue on GitHub before working."; exit 0; fi

data="$(gh issue view "$ISSUE" --json number,title,state,labels,milestone,body,comments 2>/dev/null)" || {
  echo "ai-sdlc: on issue #$ISSUE, but it couldn't be loaded (offline or no access). Read it before working."; exit 0; }

printf '%s' "$data" | jq -r '
  "ai-sdlc: this session works on issue #\(.number): \(.title) [\(.state)]",
  "Labels: \([.labels[].name] | join(", "))",
  "Milestone: \(.milestone.title // "none")",
  "The issue is the spec. If it is a sub-issue, also read its parent'"'"'s Spec. Follow the ai-sdlc skill.",
  "",
  "----- Issue body -----",
  (.body | if length > 6000 then .[0:6000] + "\n…(truncated; read the full issue)" else . end),
  "",
  "----- Latest comments -----",
  ((.comments | .[-3:] | map("[\(.author.login), \(.createdAt)]\n" + (.body | if length > 1500 then .[0:1500] + "…" else . end)) | join("\n\n")) // "none")'

#!/usr/bin/env bash
# Stop: run the project's quick checks before Claude finishes; keep working while they fail.
source "$(dirname "$0")/lib.sh"

[ "$(json .stop_hook_active)" = "true" ] && exit 0
QUICK="$(cfg .quickCheck)"
[ -z "$QUICK" ] && exit 0
[ -z "$ISSUE" ] && exit 0
[ -z "$(branch_files)" ] && exit 0

# Skip if nothing changed since the last passing run.
fp="$( { git rev-parse HEAD; git diff HEAD; git ls-files --others --exclude-standard; } 2>/dev/null | (sha256sum 2>/dev/null || shasum -a 256) | cut -c1-64)"
[ "$(cat "$CACHE/last-pass" 2>/dev/null)" = "$fp" ] && exit 0

LIMIT="$(cfg .quickCheckTimeout)"; LIMIT="${LIMIT:-300}"
if need timeout; then out="$(timeout "$LIMIT" bash -c "$QUICK" 2>&1)"; rc=$?; else out="$(bash -c "$QUICK" 2>&1)"; rc=$?; fi
if [ $rc -eq 0 ]; then echo "$fp" > "$CACHE/last-pass"; exit 0; fi

{
  echo "ai-sdlc: quick checks failed ('$QUICK', exit $rc). Fix them before finishing, or explain to the owner why you can't."
  echo "$out" | tail -40
} >&2
exit 2

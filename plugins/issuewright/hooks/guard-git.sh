#!/usr/bin/env bash
# PreToolUse on shell commands: protect main, history, gates and releases.
source "$(dirname "$0")/lib.sh"

CMD="$(json .tool_input.command)"
[ -z "$CMD" ] && exit 0
c=" $(printf '%s' "$CMD" | tr '\n' ' ') "

if [[ "$c" =~ git[[:space:]]+push ]]; then
  [[ "$c" =~ [[:space:]](-f|--force|--force-with-lease|--force-if-includes)([[:space:]=]|$) || "$c" =~ [[:space:]]\+[A-Za-z0-9_/.-]+ ]] && \
    deny "issuewright: force-pushing is never allowed. Add new commits instead."
  [[ "$c" =~ [[:space:]:]($MAIN|refs/heads/$MAIN)[[:space:]] ]] && \
    deny "issuewright: nothing is pushed to '$MAIN' directly. Push the issue branch and open a pull request."
  [[ "$c" =~ --tags || "$c" =~ [[:space:]]v[0-9]+\.[0-9] ]] && \
    deny "issuewright: release tags are pushed by the owner. Use /release to prepare everything."
fi
[[ "$c" =~ --no-verify ]] && deny "issuewright: checks can't be skipped. Fix what they report."
[[ "$c" =~ git[[:space:]]+commit && ( "$BRANCH" == "$MAIN" || -z "$BRANCH" ) ]] && \
  deny "issuewright: no commits on '$MAIN'. Work on the issue's branch."
[[ "$c" =~ gh[[:space:]]+pr[[:space:]]+merge ]] && deny "issuewright: the owner merges pull requests. Mark it ready with /ship and hand over."
[[ "$c" =~ gh[[:space:]]+release[[:space:]]+(create|upload|edit) || "$c" =~ git[[:space:]]+tag[[:space:]]+(-a[[:space:]]+|-s[[:space:]]+)?v[0-9] ]] && \
  deny "issuewright: releases are authorised by the owner. /release prepares the steps."
if [[ "$c" =~ (intent|spec|plan|test)\:[[:space:]]*(accepted|change[[:space:]]approved) ]] && [[ "$c" =~ (gh[[:space:]]+(issue|pr)[[:space:]]+edit|gh[[:space:]]+api|--add-label|labels) ]]; then
  deny "issuewright: gate labels are added by the owner only. Ask the owner to review and accept."
fi
exit 0

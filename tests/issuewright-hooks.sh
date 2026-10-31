#!/usr/bin/env bash
# Tests for the issuewright hooks. Builds throwaway repositories and a stand-in GitHub CLI.
# Run: bash tests/issuewright-hooks.sh
set -u
HOOKS="$(cd "$(dirname "$0")/../plugins/issuewright/hooks" && pwd)"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
pass=0; fail=0

# Stand-in for gh: labels come from $FAKE_LABELS (one per line); issue view returns a small issue.
mkdir -p "$WORK/bin"
cat > "$WORK/bin/gh" <<'GH'
#!/usr/bin/env bash
if [[ "$*" == *"--json labels"* ]]; then printf '%b\n' "${FAKE_LABELS:-}"; exit 0; fi
if [[ "$*" == "issue view"* ]]; then
  echo '{"number":12,"title":"Add a sticky note","state":"OPEN","labels":[{"name":"feature"}],"milestone":{"title":"0.1.9"},"body":"## Intent\nPeople need notes.","comments":[{"author":{"login":"owner"},"createdAt":"2026-10-31","body":"## Handoff\nNext: tests"}]}'
  exit 0
fi
exit 0
GH
chmod +x "$WORK/bin/gh"
export PATH="$WORK/bin:$PATH"

new_repo() { # name, with-config(yes/no)
  local d="$WORK/$1"; mkdir -p "$d/.claude" "$d/src" "$d/tests" "$d/docs"
  cd "$d" && git init -q -b main && git config user.email t@t && git config user.name t
  [ "$2" = yes ] && echo '{"sourceGlobs":["src/**"],"testGlobs":["tests/**","features/**"],"docsGlobs":["docs/**","*.md","features/**"],"quickCheck":"test -f ok"}' > .claude/issuewright.json
  echo x > src/a.rs; echo t > tests/old.rs; git add -A && git commit -qm init
}
run() { # hook, json → prints output, sets RC
  OUT="$(printf '%s' "$2" | bash "$HOOKS/$1" 2>"$WORK/err")"; RC=$?; ERR="$(cat "$WORK/err")"
}
edit() { printf '{"cwd":"%s","tool_name":"Edit","tool_input":{"file_path":"%s/%s","new_string":"%s"}}' "$PWD" "$PWD" "$1" "${2:-code}"; }
bashcmd() { printf '{"cwd":"%s","tool_name":"Bash","tool_input":{"command":"%s"}}' "$PWD" "$1"; }
expect_deny() { if [[ "$OUT" == *'"deny"'* && "$OUT" == *"$2"* ]]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL (should deny): $1"; echo "  got: $OUT"; fi; }
expect_allow() { if [[ "$OUT" != *'"deny"'* && $RC -eq 0 ]]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL (should allow): $1"; echo "  got: $OUT $ERR"; fi; }
clear_cache() { rm -rf .git/issuewright; }

# --- edit-guard ---
new_repo app yes
run edit-guard.sh "$(edit src/a.rs)";              expect_deny "edit on main" "no edits on 'main'"
git switch -qc feat/12-add-note
export FAKE_LABELS="feature"; clear_cache
run edit-guard.sh "$(edit docs/notes.md)";         expect_allow "docs before plan accepted"
run edit-guard.sh "$(edit features/notes.feature)"; expect_allow "scenarios before plan accepted"
run edit-guard.sh "$(edit src/a.rs)";              expect_deny "code before plan accepted" "no accepted plan"
export FAKE_LABELS="feature\nplan: accepted"; clear_cache
run edit-guard.sh "$(edit src/a.rs)";              expect_deny "code before any test changed" "failing test or scenario first"
echo t > tests/a_test.rs
run edit-guard.sh "$(edit src/a.rs)";              expect_allow "code after a test changed"
FAKE_KEY="AKIA""ABCDEFGHIJKLMNOP"   # made up; split so secret scanners don't flag the test
run edit-guard.sh "$(edit src/a.rs "key $FAKE_KEY")"; expect_deny "secret in content" "key, token or password"
git switch -qc chore/no-issue 2>/dev/null
run edit-guard.sh "$(edit src/a.rs)";              expect_deny "branch without issue number" "isn't linked to an issue"

# --- tests locked on fix branches ---
git switch -q main && git switch -qc fix/13-crash
export FAKE_LABELS="bug\nplan: accepted"; clear_cache
echo failing > tests/crash.rs && git add -A && git commit -qm "failing test"
run edit-guard.sh "$(edit tests/crash.rs)";        expect_deny "edit committed failing test" "Fix the code, not the test"
run edit-guard.sh "$(edit src/a.rs)";              expect_allow "fix the code"
export FAKE_LABELS="bug\nplan: accepted\ntest: change approved"; clear_cache
run edit-guard.sh "$(edit tests/crash.rs)";        expect_allow "owner approved test change"

# --- repositories that haven't opted in ---
new_repo other no
run edit-guard.sh "$(edit src/a.rs)";              expect_allow "no config: hooks stay out of the way"

# --- guard-git ---
cd "$WORK/app" && git switch -q feat/12-add-note
for c in "git push --force" "git push -f origin feat/12-add-note" "git push origin main" "git push origin HEAD:main" "gh pr merge 5 --squash" "git commit --no-verify -m x" "gh release create v0.1.0" "git tag v0.1.0" "git push origin --tags" "gh issue edit 12 --add-label 'plan: accepted'"; do
  run guard-git.sh "$(bashcmd "$c")"; expect_deny "$c" "issuewright"
done
for c in "git push -u origin feat/12-add-note" "git commit -m 'Add note'" "gh pr create --draft --title x --body 'Closes #12'" "gh issue comment 12 --body handoff" "git status"; do
  run guard-git.sh "$(bashcmd "$c")"; expect_allow "$c"
done
git switch -q main
run guard-git.sh "$(bashcmd "git commit -m x")";   expect_deny "commit on main" "no commits on 'main'"

# --- checks-before-done ---
git switch -q feat/12-add-note
echo y > tests/b_test.rs   # a change on the branch, so checks apply
run checks-before-done.sh "{\"cwd\":\"$PWD\",\"stop_hook_active\":false}"
if [ $RC -eq 2 ] && [[ "$ERR" == *"quick checks failed"* ]]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: failing checks should keep Claude working (rc=$RC)"; fi
run checks-before-done.sh "{\"cwd\":\"$PWD\",\"stop_hook_active\":true}"
if [ $RC -eq 0 ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: must not loop when already continuing"; fi
git stash -q -u && run checks-before-done.sh "{\"cwd\":\"$PWD\",\"stop_hook_active\":false}" && git stash pop -q
if [ $RC -eq 0 ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: no changes on the branch means no checks"; fi
touch ok
run checks-before-done.sh "{\"cwd\":\"$PWD\",\"stop_hook_active\":false}"
if [ $RC -eq 0 ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: passing checks should let Claude finish"; fi

# --- load-issue ---
run load-issue.sh "{\"cwd\":\"$PWD\",\"source\":\"startup\"}"
if [[ "$OUT" == *"issue #12: Add a sticky note"* && "$OUT" == *"Handoff"* ]]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: load-issue should print the issue"; echo "$OUT"; fi
git switch -q main
run load-issue.sh "{\"cwd\":\"$PWD\",\"source\":\"startup\"}"
if [[ "$OUT" == *"isn't an issue branch"* ]]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: load-issue on main"; fi

echo "issuewright hooks: $pass passed, $fail failed"
[ $fail -eq 0 ]

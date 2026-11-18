#!/bin/sh
# Stop hook: before Claude finishes a turn, compile main and test code in every service with uncommitted Java/pom changes.
# Exit 2 sends the compiler errors back to Claude so it keeps working. Tests are not run here (too slow); CLAUDE.md "Done means" covers them.
. "${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/lib.sh"

input=$(cat)
# Don't block a second time if Claude is already continuing because of this hook.
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0

root="${CLAUDE_PROJECT_DIR:-.}"
cd "$root" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Changed files (staged, unstaged, untracked); for renames keep the new path.
modules=$(git status --porcelain --untracked-files=all \
  | sed -e 's/^...//' -e 's/.* -> //' \
  | grep -E '\.java$|pom\.xml$' \
  | while read -r f; do module_dir "$root/$f"; done | sort -u)
[ -n "$modules" ] || exit 0

failed=0
for mod in $modules; do
  cmd="$(mvn_for "$mod") -q test-compile"
  out=$(cd "$mod" && $cmd 2>&1) && continue
  failed=1
  echo "Compile failed in ${mod#$root/} ($cmd):" >&2
  errors=$(printf '%s\n' "$out" | grep -E 'ERROR|error:|BUILD FAILURE' | head -30)
  if [ -n "$errors" ]; then printf '%s\n' "$errors" >&2; else printf '%s\n' "$out" | tail -30 >&2; fi
done
[ $failed -eq 0 ] || { echo "Fix these before finishing." >&2; exit 2; }
exit 0

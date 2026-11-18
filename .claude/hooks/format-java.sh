#!/bin/sh
# PostToolUse hook: format a Java file right after Claude edits it.
# Uses Spotless if that service's pom.xml configures it, else google-java-format if installed, else nothing.
# It never blocks Claude.
. "${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/lib.sh"

file=$(jq -r '.tool_input.file_path // empty')
case "$file" in
  *.java) ;;
  *) exit 0 ;;
esac
[ -f "$file" ] || exit 0

if mod=$(module_dir "$file") && grep -q "spotless-maven-plugin" "$mod/pom.xml"; then
  (cd "$mod" && $(mvn_for "$mod") -q spotless:apply -DspotlessFiles="$file" >/dev/null 2>&1)
elif command -v google-java-format >/dev/null 2>&1; then
  google-java-format --replace "$file" >/dev/null 2>&1
fi
exit 0

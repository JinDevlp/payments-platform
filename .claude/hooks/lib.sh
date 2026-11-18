#!/bin/sh
# Shared helpers for the hooks. This repo has one Maven project per service folder.

# Print the nearest directory at or above $1 that contains pom.xml, stopping at the project root.
module_dir() {
  d=$(dirname "$1")
  root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    if [ -f "$d/pom.xml" ]; then printf '%s\n' "$d"; return 0; fi
    [ "$d" = "$root" ] && return 1
    d=$(dirname "$d")
  done
  return 1
}

# Print the Maven command for a module: its wrapper if present, else mvn.
mvn_for() {
  if [ -x "$1/mvnw" ]; then printf '%s\n' "./mvnw"; else printf '%s\n' "mvn"; fi
}

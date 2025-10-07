#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://fernando-tupana.github.io/projects_map}"

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

TMPFILE=$(mktemp)
printf "%s\n" "# projects_map" >> "$TMPFILE"
printf "%s\n\n" "" >> "$TMPFILE"
printf "%s\n" "This repository contains several static site folders. Below are convenient links to the deployed web pages (Netlify) for each top-level folder." >> "$TMPFILE"
printf "%s\n\n" "" >> "$TMPFILE"
printf "%s\n" "## Web pages" >> "$TMPFILE"
printf "%s\n\n" "" >> "$TMPFILE"

for f in *; do
  if [ -d "$f" ]; then
    case "$f" in
      .git|node_modules|.github|.vscode|dist|scripts|docs) continue ;;
    esac
  # Use echo -- to avoid issues if the line starts with '-'
  printf '%s\n' "- [$f](${BASE_URL%/}/$f)" >> "$TMPFILE"
  fi
done

printf "%s\n" "" >> "$TMPFILE"
printf "%s\n" "If the base deployment URL differs for any site, update the links above accordingly." >> "$TMPFILE"
printf "%s\n\n" "" >> "$TMPFILE"
printf '%s\n\n' '---' >> "$TMPFILE"
printf '%s\n' 'Generated: updated README with links to each top-level folder web page by GitHub Action.' >> "$TMPFILE"

if [ -f README.md ] && cmp -s "$TMPFILE" README.md; then
  echo "README.md already up to date"
  rm -f "$TMPFILE"
  exit 0
fi

mv "$TMPFILE" README.md

if git status --porcelain | grep -q README.md; then
  git add README.md
  git -c user.name="github-actions[bot]" -c user.email="41898282+github-actions[bot]@users.noreply.github.com" commit -m "chore: update README web pages list"
  git push origin HEAD
else
  echo "No changes to commit"
fi

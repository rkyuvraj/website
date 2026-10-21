#!/bin/sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
find content/posts content/til -name index.md -type f | while IFS= read -r file; do
awk '
FNR == 1 { front=0; draft=0; empty=1 }
/^\+\+\+[[:space:]]*$/ { front++; next }
front == 1 && /^draft[[:space:]]*=[[:space:]]*true([[:space:]]|#|$)/ { draft=1 }
front == 1 && /^description[[:space:]]*=/ {
  value=$0; sub(/^[^=]*=[[:space:]]*/, "", value)
  empty=(value ~ /^"[[:space:]]*"[[:space:]]*(#.*)?$/ || value ~ /^\047[[:space:]]*\047[[:space:]]*(#.*)?$/)
}
END { if (!draft && empty) { print FILENAME ": published content needs a description" > "/dev/stderr"; exit 1 } }
' "$file" || exit 1
done

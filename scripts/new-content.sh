#!/bin/sh
set -eu
usage() { echo "Usage: $0 post|til lowercase-kebab-slug" >&2; exit 1; }
[ "$#" -eq 2 ] || usage
case "$1" in post) section=posts; toc=true ;; til) section=til; toc=false ;; *) usage ;; esac
printf '%s\n' "$2" | LC_ALL=C awk '/^[a-z0-9]+(-[a-z0-9]+)*$/ { valid=1 } END { exit !valid }' || usage
cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
folder="content/$section/$2"
# mkdir is atomic and refuses existing directories, including empty ones.
mkdir "$folder" || exit 1
title=$(printf '%s\n' "$2" | awk -F- '{for(i=1;i<=NF;i++) printf "%s%s%s", (i>1?" ":""), toupper(substr($i,1,1)), substr($i,2); print ""}')
cat > "$folder/index.md" <<FRONTMATTER
+++
title = "$title"
description = ""
date = $(date +%F)
draft = true

[taxonomies]
tags = []

[extra]
toc = $toc
+++
FRONTMATTER
if [ "$1" = til ]; then
  cat >> "$folder/index.md" <<'BODY'

## What I learned

TODO:

## Example

TODO:

## Source

TODO:
BODY
fi
printf 'Created %s/index.md\nFill in description and edit the title (especially acronyms); set draft = false when ready.\n' "$folder"

#!/usr/bin/env bash
set -euo pipefail

# You must be logged into Patreon in the browser below for this to work.
BROWSER="${BROWSER:-chrome}"
OUTDIR="${OUTDIR:-$HOME/Patreon}"
ARCHIVE="${ARCHIVE:-$HOME/.patreon-download-archive.txt}"

usage() {
  cat <<'EOF'
Usage:
  patreon-dl.sh <creator-slug|full-url> [more creators...]
  patreon-dl.sh --list /path/to/creators.txt

Examples:
  patreon-dl.sh maplemist
  patreon-dl.sh https://www.patreon.com/somecreator/posts

Env overrides:
  BROWSER=firefox|chrome|brave ...
  OUTDIR=/path/to/output   (default ~/Patreon)
  ARCHIVE=/path/to/file    (skip already-downloaded posts)

Recommended first run, to log in (answers password/IP prompts once):
  patreon-dl.sh login
EOF
}

login() {
  echo "One-time login. Enter a fake username/password when prompted;"
  echo "the login flow just needs to activate your browser session."
  yt-dlp --cookies-from-browser "$BROWSER" \
    --username dummy --password dummy \
    --print "%(title)s" \
    https://www.patreon.com/login >/dev/null
  echo "Login check done."
}

slug_of() {
  local url="$1"
  local slug
  slug="$(printf '%s' "$url" | sed -E 's#^https?://(www\.)?patreon\.com/##; s#/.*$##; s#\?.*$##')"
  printf '%s' "$slug"
}

download_creator() {
  local input="$1"
  local slug; slug="$(slug_of "$input")"
  local dest="$OUTDIR/$slug"
  local yt_url

  if [[ "$input" =~ /posts/[0-9]+ ]]; then
    yt_url="$input"
  else
    yt_url="https://www.patreon.com/${slug}/posts"
  fi

  mkdir -p "$dest"
  yt-dlp \
    --cookies-from-browser "$BROWSER" \
    --download-archive "$ARCHIVE" \
    --limit-rate 5M \
    --concurrent-fragments 4 \
    --continue \
    --no-part \
    --embed-metadata \
    --embed-thumbnail \
    --add-metadata \
    --write-info-json \
    --output "$dest/%(upload_date)s %(title).180B [%(id)s].%(ext)s" \
    --restrict-filenames \
    --match-filter "!was_live" \
    -f "bv*+ba/b" \
    "$yt_url"
}

case "${1:-}" in
  ""|-h|--help) usage; exit 0 ;;
  login) login ;;
  --list)
    listfile="$2"
    while IFS= read -r line; do
      [[ -z "$line" || "$line" == \#* ]] && continue
      echo ">>> $line"
      download_creator "$line"
    done < "$listfile"
    ;;
  *)
    for creator in "$@"; do
      echo ">>> $creator"
      download_creator "$creator"
    done
    ;;
esac

echo "Done."
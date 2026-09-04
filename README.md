# patreon-dl

Download videos from Patreon creators you're subscribed to, using `yt-dlp`.

## Prerequisites

- **Linux/macOS** with `bash` and `sed`
- **`yt-dlp`** and **`ffmpeg`** on your `PATH` (needed for media merging/thumbnail embedding)
- Logged into Patreon in a supported browser (see below)

```bash
# yt-dlp (no pip required)
curl -L -o ~/.local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
chmod +x ~/.local/bin/yt-dlp

# ffmpeg
# Debian/Ubuntu:   sudo apt install ffmpeg
# macOS (Homebrew): brew install ffmpeg
```

## Setup

Make it executable, then activate your browser session once:

```bash
chmod +x patreon-dl.sh
./patreon-dl.sh login
```

The `login` command just runs a `yt-dlp` login flow against Patreon using your
browser's session. It needs your logged-in cookies, so be signed in to Patreon
in the target browser when you run it (you may get a keyring password prompt).

By default the script pulls cookies from **Chrome**. If you use another
browser, set `BROWSER`:

```bash
BROWSER=firefox ./patreon-dl.sh ...
# or any browser supported by yt-dlp's --cookies-from-browser
```

## Usage

```bash
# One creator (downloads all their posts)
./patreon-dl.sh creator-slug

# Many creators
./patreon-dl.sh slug1 slug2 slug3

# A single post by URL
./patreon-dl.sh https://www.patreon.com/GoodJoint/posts/59th-private-2x1-167116767

# Bulk from a file (one creator/URL per line, blank lines and # comments ignored)
./patreon-dl.sh --list creators.txt
```

## Output

Files are saved to `~/Patreon/<creator-slug>/` named like
`YYYYMMDD Title [post-id].mp4`. Each video downloads in the best available
quality with metadata and thumbnail embedded (`bv*+ba/b`).

## Configuration (env vars)

| Variable   | Default                        | Purpose                                       |
|------------|--------------------------------|-----------------------------------------------|
| `BROWSER`  | `chrome`                       | Browser to pull login cookies from            |
| `OUTDIR`   | `~/Patreon`                    | Output directory                              |
| `ARCHIVE`  | `~/.patreon-download-archive.txt` | Tracks completed downloads to skip the next time |

Example:

```bash
OUTDIR=/media/videos ./patreon-dl.sh maplemist
```

## Legal

Only download content you are entitled to access (i.e. posts you have paid for
or are granted as a subscriber). Re-distributing that content is against
Patreon's Terms of Service and may violate copyright.

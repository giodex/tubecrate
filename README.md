<div align="center">

# Tubecrate

**Search YouTube and drop tracks straight into your DJ crate — from the macOS menu bar.**

A native SwiftUI menu bar app that finds tracks on YouTube, downloads the
best available audio, transcodes to a Rekordbox-ready format, tags it with
artwork, and files it into a folder you choose.

![platform](https://img.shields.io/badge/platform-macOS%2014%2B-black)
![swift](https://img.shields.io/badge/Swift-6-orange)
![license](https://img.shields.io/badge/license-MIT-blue)

</div>

> Tubecrate is a fork of [**Cratebar**](https://github.com/JackTPatterson/cratebar)
> by Jack Patterson, reworked to search and download from **YouTube** instead of
> SoundCloud.

---

## Features

- 🔎 **Search YouTube** right from the menu bar — no browser, no API key
- ⬇️ **Best-quality downloads** via [`yt-dlp`](https://github.com/yt-dlp/yt-dlp): grabs the highest-bitrate audio-only stream
- 🎛️ **DJ-ready formats** via [`ffmpeg`](https://ffmpeg.org): **AIFF** (Rekordbox-native), WAV, MP3 320, or keep the original
- 🏷️ **Full metadata** — embeds ID3 tags (title / artist / album / genre) **and cover art**
- 📁 **Your folder, your rules** — pick a "record box" directory, optionally split into per-artist subfolders
- 🏷️ **Clean tags** — "Artist - Title" video titles are split into proper artist/title fields
- 🍺 **Zero-fuss setup** — installs `yt-dlp` + `ffmpeg` for you via Homebrew
- 🪶 **Truly native & lightweight** — `MenuBarExtra`, no Dock icon, no Electron

> **A note on audio quality.** YouTube audio is lossy at the source (typically
> Opus ~160 kbps or AAC 128 kbps). Tubecrate always grabs the best available
> stream — transcoding to AIFF gives you a clean, lossless *container*
> with full metadata, but it can't manufacture detail the source doesn't contain.

---

## Screenshots

> _The app lives in your menu bar. Click the icon to search; the gear opens Settings._

```
┌─────────────────────────────────┐
│ 🎵 Tubecrate            ⚙︎  ⏻     │
├─────────────────────────────────┤
│ 🔎 daft punk                  ✕ │
├─────────────────────────────────┤
│ ▸ Downloads                     │
│   ✓ Around the World   Saved 🔍 │
├─────────────────────────────────┤
│ ▦  Around the World             │
│    Daft Punk            7:09  ⬇ │
│ ▦  One More Time                │
│    Daft Punk            5:20  ⬇ │
└─────────────────────────────────┘
```

---

## Requirements

- **macOS 14 (Sonoma) or later**
- **Xcode / Swift 6 toolchain** to build (`xcode-select --install` provides the basics; full Xcode recommended)
- **[`yt-dlp`](https://github.com/yt-dlp/yt-dlp)** and **[`ffmpeg`](https://ffmpeg.org)** — Tubecrate can install these for you via [Homebrew](https://brew.sh) on first run

---

## Install

### Direct download

Grab `Tubecrate-<version>.zip` from the
[latest release](https://github.com/giodex/tubecrate/releases/latest),
unzip it, and drag **Tubecrate.app** to Applications. You'll also need `yt-dlp`
and `ffmpeg` (`brew install yt-dlp ffmpeg`, or let Tubecrate install them from
Settings on first run).

The release build is **ad-hoc signed** (not notarized), so on first launch
right-click the app → **Open**, or run
`xattr -dr com.apple.quarantine /Applications/Tubecrate.app`.

### Build from source

```bash
git clone https://github.com/giodex/tubecrate.git
cd tubecrate

# Build a proper menu-bar .app bundle
./Scripts/build-app.sh

# Launch it
open build/Tubecrate.app

# (optional) move it into /Applications
cp -R build/Tubecrate.app /Applications/
```

Prefer to run straight from source while hacking on it:

```bash
swift run Tubecrate
```

A small **record-stack** icon appears in your menu bar. Click it to start.

---

## First run

1. Click the menu bar icon → **gear** (Settings).
2. If **yt-dlp** / **ffmpeg** show as missing, click **Install via Homebrew**.
3. Choose your **record box folder** (defaults to `~/Music/Tubecrate`).
4. Pick your **audio format** (defaults to AIFF).
5. Back on the search screen, search a track and hit the **download arrow** ⬇.

Then point Rekordbox at your record box folder (or drag the files in) and they
import with artwork and tags intact.

---

## How it works

```
Search   →  yt-dlp "ytsearch30:<query>" --flat-playlist --dump-json
            (metadata only — no API key, no per-video resolution)

Download →  yt-dlp -f "bestaudio/best" -S abr,asr   (+ cover thumbnail)
            └─ retried up to 3× (YouTube intermittently returns 403)

Convert  →  ffmpeg → AIFF / WAV / MP3, ID3v2 tags + attached cover art
            (cover embed has an audio-only fallback if a muxer rejects it)

Place    →  moved into your folder as "Artist - Title.aiff"
            (optionally Artist/ subfolders, with collision-safe naming)
```

---

## Project layout

```
Sources/Tubecrate/
  TubecrateApp.swift         App entry — MenuBarExtra, accessory (no Dock icon)
  AppState.swift            Observable app state (search, downloads, settings)
  Models/
    Track.swift             Track + yt-dlp JSON decoding
    Settings.swift          AppSettings (persisted) + AudioFormat
    DownloadItem.swift       Per-download progress/status
  Services/
    YouTubeClient.swift      YouTube search via yt-dlp ytsearch
    Downloader.swift         yt-dlp → ffmpeg → tag → move pipeline
    ProcessRunner.swift      async subprocess runner with line streaming
    ToolLocator.swift        finds yt-dlp / ffmpeg / brew
  Views/
    RootView.swift           header + screen switching
    SearchView.swift         search bar, results, setup notice
    DownloadsStrip.swift     active/recent downloads list
    SettingsView.swift       folder, format, tools
Scripts/
  build-app.sh              Packages the binary into Tubecrate.app
```

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Menu bar icon doesn't appear | Make sure the build succeeded; relaunch with `open build/Tubecrate.app`. |
| "No tracks found" / search errors | YouTube changes often — update yt-dlp (`brew upgrade yt-dlp`) and try again. |
| Downloads fail immediately | Check Settings — `yt-dlp` and `ffmpeg` must both be green. |
| "app can't be opened" (Gatekeeper) | The bundle is ad-hoc signed. Right-click → **Open**, or `xattr -dr com.apple.quarantine build/Tubecrate.app`. |

---

## Legal & ethics

Tubecrate is a personal tool. **Only download tracks you have the right to
download.** Respect [YouTube's Terms of Service](https://www.youtube.com/t/terms)
and the rights of artists and rightsholders. The author accepts no liability for
misuse.

---

## License

[MIT](LICENSE) © 2026 Jack Patterson

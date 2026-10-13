import Foundation

/// A single YouTube video returned from a yt-dlp `ytsearch` query.
struct Track: Identifiable, Hashable {
    let id: String
    let title: String
    let artist: String
    let durationSeconds: Int
    let url: String

    var durationFormatted: String {
        guard durationSeconds > 0 else { return "–:––" }
        let h = durationSeconds / 3600
        let m = (durationSeconds % 3600) / 60
        let s = durationSeconds % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }

    /// Thumbnail served by YouTube's image CDN (stable, no API key needed).
    var artworkURL: URL? {
        URL(string: "https://i.ytimg.com/vi/\(id)/mqdefault.jpg")
    }
}

// MARK: - Wire decoding (yt-dlp `--flat-playlist --dump-json` shape)

struct YTEntryWire: Decodable {
    let id: String?
    let title: String?
    let duration: Double?
    let channel: String?
    let uploader: String?
    let url: String?
    let webpage_url: String?
    let live_status: String?

    /// Convert a wire object into a clean `Track`, or `nil` if it isn't a usable video.
    func toTrack() -> Track? {
        guard let id, let rawTitle = title, live_status != "is_live", live_status != "is_upcoming"
        else { return nil }
        let channelName = (channel ?? uploader ?? "Unknown Artist")
            .replacingOccurrences(of: " - Topic", with: "")
        let (artist, songTitle) = Self.splitArtist(rawTitle, fallbackArtist: channelName)
        return Track(
            id: id,
            title: songTitle,
            artist: artist,
            durationSeconds: Int(duration ?? 0),
            url: webpage_url ?? url ?? "https://www.youtube.com/watch?v=\(id)"
        )
    }

    /// Music uploads are usually titled "Artist - Title (Official Video)". Split on the
    /// first dash so tags come out clean; otherwise fall back to the channel name.
    private static func splitArtist(_ title: String, fallbackArtist: String) -> (String, String) {
        for sep in [" - ", " – ", " — "] {
            if let r = title.range(of: sep) {
                let artist = title[..<r.lowerBound].trimmingCharacters(in: .whitespaces)
                let song = title[r.upperBound...].trimmingCharacters(in: .whitespaces)
                if !artist.isEmpty, !song.isEmpty { return (artist, song) }
            }
        }
        return (fallbackArtist, title)
    }
}

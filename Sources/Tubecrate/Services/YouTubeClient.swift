import Foundation

enum YTError: LocalizedError {
    case missingYtDlp
    case searchFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingYtDlp:          return "yt-dlp not installed."
        case .searchFailed(let msg): return "YouTube search failed: \(msg)"
        }
    }
}

/// Searches YouTube through yt-dlp's `ytsearchN:` pseudo-URL. No API key needed,
/// and it reuses the tool we already depend on for downloads.
struct YouTubeClient {
    let ytDlpPath: String

    func search(_ query: String, limit: Int = 30) async throws -> [Track] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let result = try await ProcessRunner.run(ytDlpPath, [
            "ytsearch\(limit):\(trimmed)",
            "--flat-playlist",   // metadata only, don't resolve each video
            "--dump-json",
            "--no-warnings",
            "--ignore-errors",
        ])

        let decoder = JSONDecoder()
        let tracks = result.output
            .split(whereSeparator: \.isNewline)
            .compactMap { line -> Track? in
                guard line.first == "{" else { return nil }
                return (try? decoder.decode(YTEntryWire.self, from: Data(line.utf8)))?.toTrack()
            }

        if tracks.isEmpty, result.exitCode != 0 {
            let tail = result.output.split(whereSeparator: \.isNewline).suffix(2).joined(separator: " ")
            throw YTError.searchFailed(tail)
        }
        return tracks
    }
}

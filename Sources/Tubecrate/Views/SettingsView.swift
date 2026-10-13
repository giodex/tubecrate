import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                librarySection
                Divider()
                formatSection
                Divider()
                toolsSection
            }
            .padding(14)
        }
    }

    // MARK: - Library folder

    private var librarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Record box folder")
            Text("Tracks are saved here with tags + artwork. Point Rekordbox at this folder.")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text(state.settings.downloadDirectory)
                    .font(.system(size: 11, design: .monospaced))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                Button("Choose…") { chooseFolder() }
            }
            HStack {
                Toggle("Organize into per-artist subfolders", isOn: Binding(
                    get: { state.settings.organizeByArtist },
                    set: { newValue in state.updateSettings { $0.organizeByArtist = newValue } }
                ))
                .toggleStyle(.checkbox)
                .font(.callout)
                Spacer()
                Button("Open") { state.openDownloadFolder() }
                    .font(.caption)
            }
        }
    }

    // MARK: - Format

    private var formatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Audio format")
            Picker("", selection: Binding(
                get: { state.settings.format },
                set: { newValue in state.updateSettings { $0.format = newValue } }
            )) {
                ForEach(AudioFormat.allCases) { fmt in
                    Text(fmt.label).tag(fmt)
                }
            }
            .labelsHidden()
            .pickerStyle(.radioGroup)

            Text("YouTube audio is lossy at the source (typically Opus ~160 kbps or AAC 128 kbps). " +
                 "Transcoding can't add detail that isn't there — AIFF gives Rekordbox a " +
                 "clean, lossless container with full metadata.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Tools

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Required tools")
            toolStatusRow("yt-dlp", installed: state.tools.ytDlpInstalled, path: state.tools.ytDlpPath)
            toolStatusRow("ffmpeg", installed: state.tools.ffmpegInstalled, path: state.tools.ffmpegPath)

            if !state.tools.allInstalled {
                HStack {
                    if ToolLocator.brewPath != nil {
                        Button {
                            state.installToolsWithHomebrew()
                        } label: {
                            Label("Install via Homebrew", systemImage: "shippingbox")
                        }
                        .disabled(state.isInstallingTools)
                    } else {
                        Text("Homebrew not found. Install from brew.sh, then run `brew install yt-dlp ffmpeg`.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if state.isInstallingTools { ProgressView().controlSize(.small) }
                    Button("Recheck") { state.tools.refresh() }
                        .font(.caption)
                }
            } else {
                Button("Recheck") { state.tools.refresh() }
                    .font(.caption)
            }

            if !state.installLog.isEmpty {
                ScrollView {
                    Text(state.installLog)
                        .font(.system(size: 10, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(height: 90)
                .background(.black.opacity(0.06), in: RoundedRectangle(cornerRadius: 6))
            }
        }
    }

    // MARK: - Bits

    private func sectionTitle(_ text: String) -> some View {
        Text(text).font(.headline)
    }

    private func toolStatusRow(_ name: String, installed: Bool, path: String?) -> some View {
        HStack(spacing: 6) {
            Image(systemName: installed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(installed ? .green : .red)
            Text(name).font(.callout.weight(.medium))
            Spacer()
            Text(installed ? (path ?? "") : "not found")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: state.settings.downloadDirectory)
        if panel.runModal() == .OK, let url = panel.url {
            state.updateSettings { $0.downloadDirectory = url.path }
        }
    }
}

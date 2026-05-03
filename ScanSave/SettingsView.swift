import SwiftUI

/// A settings screen where users configure the PDF file naming pattern.
///
/// - Prefix: a custom string prepended to the date (e.g. `"S-24"`).
/// - Date format: one of three date/time suffix options.
/// - Preview: shows the resulting file name in real time.
struct SettingsView: View {
    @AppStorage("filePrefix") private var filePrefix = "S-24"
    @AppStorage("dateFormat") private var dateFormatRaw = DateFormat.dateOnly.rawValue
    @AppStorage("autoScanOnLaunch") private var autoScanOnLaunch = false

    var body: some View {
        NavigationStack {
            Form {
                behaviorSection
                prefixSection
                dateFormatSection
                previewSection
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Sections

    private var behaviorSection: some View {
        Section("Behavior") {
            Toggle(isOn: $autoScanOnLaunch) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Auto-scan on launch")
                    Text("Opens the scanner automatically when the app starts.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var prefixSection: some View {
        Section("File Name Configuration") {
            HStack {
                Text("Prefix")
                Spacer()
                TextField("e.g. S-24", text: $filePrefix)
                    .multilineTextAlignment(.trailing)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
        }
    }

    private var dateFormatSection: some View {
        Section("Date Format") {
            ForEach(DateFormat.allCases) { format in
                Button {
                    dateFormatRaw = format.rawValue
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(format.label)
                                .foregroundStyle(.primary)
                            Text(format.example)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if dateFormatRaw == format.rawValue {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
    }

    private var previewSection: some View {
        Section("Preview") {
            HStack {
                Text("Result")
                Spacer()
                Text(fileNamePreview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospaced()
            }
        }
    }

    // MARK: - Preview

    private var fileNamePreview: String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatRaw
        let dateString = formatter.string(from: Date())
        let cleanPrefix = filePrefix.trimmingCharacters(in: .whitespaces)
        return "\(cleanPrefix) \(dateString).pdf"
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

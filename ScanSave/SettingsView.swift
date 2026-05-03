import SwiftUI

struct SettingsView: View {
    @AppStorage("filePrefix") private var filePrefix = "S-24"
    @AppStorage("dateFormat") private var dateFormatRaw = DateFormat.dateOnly.rawValue

    private var selectedFormat: Binding<DateFormat> {
        Binding(
            get: { DateFormat(rawValue: dateFormatRaw) ?? .dateOnly },
            set: { dateFormatRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
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
            .navigationTitle("Settings")
        }
    }

    private var fileNamePreview: String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatRaw
        let dateString = formatter.string(from: Date())
        let cleanPrefix = filePrefix.trimmingCharacters(in: .whitespaces)
        return "\(cleanPrefix)_\(dateString).pdf"
    }
}

#Preview {
    SettingsView()
}

import Foundation

/// Represents the available date format options for PDF file names.
///
/// Each case maps to a `DateFormatter` format string. The raw values
/// are the format strings themselves, making persistence straightforward
/// via `@AppStorage`.
enum DateFormat: String, CaseIterable, Identifiable {
    /// Example: `2026-05-03`
    case dateOnly = "yyyy-MM-dd"

    /// Example: `2026-05-03 16h53`
    case dateTime = "yyyy-MM-dd HH'h'mm"

    /// Example: `2026-05-03 16h53m47s`
    case dateTimeSeconds = "yyyy-MM-dd HH'h'mm'm'ss's'"

    var id: String { rawValue }

    /// A human-readable label shown in the settings UI.
    var label: String {
        switch self {
        case .dateOnly: return "YYYY-MM-DD"
        case .dateTime: return "YYYY-MM-DD HHhMM"
        case .dateTimeSeconds: return "YYYY-MM-DD HHhMMmSSs"
        }
    }

    /// A live preview of the format using the current date and time.
    var example: String {
        let formatter = DateFormatter()
        formatter.dateFormat = rawValue
        return formatter.string(from: Date())
    }
}

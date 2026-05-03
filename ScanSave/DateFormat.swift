import Foundation

enum DateFormat: String, CaseIterable, Identifiable {
    case dateOnly = "yyyy-MM-dd"
    case dateTime = "yyyy-MM-dd HH'h'mm"
    case dateTimeSeconds = "yyyy-MM-dd HH'h'mm'm'ss's'"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dateOnly: return "YYYY-MM-DD"
        case .dateTime: return "YYYY-MM-DD HHhMM"
        case .dateTimeSeconds: return "YYYY-MM-DD HHhMMmSSs"
        }
    }

    var example: String {
        let formatter = DateFormatter()
        formatter.dateFormat = rawValue
        return formatter.string(from: Date())
    }
}

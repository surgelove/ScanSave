import Foundation

enum DateFormat: String, CaseIterable, Identifiable {
    case dateOnly = "yyyy-MM-dd"
    case dateTime = "yyyy-MM-dd HH:mm"
    case dateTimeSeconds = "yyyy-MM-dd HH:mm:ss"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dateOnly: return "YYYY-MM-DD"
        case .dateTime: return "YYYY-MM-DD HH:MM"
        case .dateTimeSeconds: return "YYYY-MM-DD HH:MM:SS"
        }
    }

    var example: String {
        let formatter = DateFormatter()
        formatter.dateFormat = rawValue
        return formatter.string(from: Date())
    }
}

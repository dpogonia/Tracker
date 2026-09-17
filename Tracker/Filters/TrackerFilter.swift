import Foundation

enum TrackerFilter: Int, CaseIterable {
    case all
    case today
    case completed
    case incomplete

    var title: String {
        switch self {
        case .all:
            L10n.filterAll
        case .today:
            L10n.filterToday
        case .completed:
            L10n.filterCompleted
        case .incomplete:
            L10n.filterIncomplete
        }
    }

    var showsCheckmark: Bool {
        self == .completed || self == .incomplete
    }
}

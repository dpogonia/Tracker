import Foundation

enum WeekDay: Int, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1

    var name: String {
        switch self {
        case .monday: L10n.monday
        case .tuesday: L10n.tuesday
        case .wednesday: L10n.wednesday
        case .thursday: L10n.thursday
        case .friday: L10n.friday
        case .saturday: L10n.saturday
        case .sunday: L10n.sunday
        }
    }

    var shortName: String {
        switch self {
        case .monday: L10n.mondayShort
        case .tuesday: L10n.tuesdayShort
        case .wednesday: L10n.wednesdayShort
        case .thursday: L10n.thursdayShort
        case .friday: L10n.fridayShort
        case .saturday: L10n.saturdayShort
        case .sunday: L10n.sundayShort
        }
    }
}

extension Set where Element == WeekDay {
    var storedValue: String {
        WeekDay.allCases
            .filter { contains($0) }
            .map { String($0.rawValue) }
            .joined(separator: ",")
    }

    init(storedValue: String?) {
        guard let storedValue, !storedValue.isEmpty else {
            self = []
            return
        }
        self = Set(
            storedValue
                .split(separator: ",")
                .compactMap { Int($0).flatMap(WeekDay.init(rawValue:)) }
        )
    }
}

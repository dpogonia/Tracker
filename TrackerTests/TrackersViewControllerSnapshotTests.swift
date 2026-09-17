import CoreData
import SnapshotTesting
import UIKit
import XCTest
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {
    private static let stack = CoreDataStack.shared

    override func setUp() {
        super.setUp()
        let context = Self.stack.context
        for entityName in ["TrackerRecordCoreData", "TrackerCoreData", "TrackerCategoryCoreData"] {
            let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
            try? context.fetch(request).forEach(context.delete)
        }
        try? context.save()
    }

    func testMainScreenLight() throws {
        let viewController = try makeViewController()
        assertSnapshot(
            of: viewController,
            as: .image(
                on: .iPhoneSe,
                traits: .init(userInterfaceStyle: .light)
            )
        )
    }

    func testMainScreenDark() throws {
        let viewController = try makeViewController()
        assertSnapshot(
            of: viewController,
            as: .image(
                on: .iPhoneSe,
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }

    private func makeViewController() throws -> UIViewController {
        let trackerStore = TrackerStore(context: Self.stack.context)
        let categoryStore = TrackerCategoryStore(context: Self.stack.context)
        let recordStore = TrackerRecordStore(context: Self.stack.context)
        let tracker = Tracker(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Water",
            color: .ypBlue,
            emoji: "💧",
            schedule: Set(WeekDay.allCases)
        )
        try trackerStore.add(tracker, to: "Health")

        let viewController = TrackersViewController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )
        return UINavigationController(rootViewController: viewController)
    }
}

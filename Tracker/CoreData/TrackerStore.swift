import CoreData
import UIKit

protocol StoreDelegate: AnyObject {
    func storeDidUpdate()
}

@objc(TrackerCoreData)
final class TrackerCoreData: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var emoji: String
    @NSManaged var colorHex: String
    @NSManaged var schedule: String?
    @NSManaged var category: TrackerCategoryCoreData
    @NSManaged var records: NSSet
}

extension TrackerCoreData {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    func toTracker() -> Tracker {
        let scheduleSet = Set<WeekDay>(storedValue: schedule)
        return Tracker(
            id: id,
            name: name,
            color: UIColor(hex: colorHex) ?? .ypBlue,
            emoji: emoji,
            schedule: scheduleSet.isEmpty ? nil : scheduleSet
        )
    }
}

final class TrackerStore: NSObject {
    weak var delegate: StoreDelegate?

    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        try? fetchedResultsController.performFetch()
    }

    func fetchTrackers() -> [Tracker] {
        fetchedResultsController.fetchedObjects?.map { $0.toTracker() } ?? []
    }

    func add(_ tracker: Tracker, to categoryTitle: String) throws {
        let category = try fetchOrCreateCategory(title: categoryTitle)
        let object = TrackerCoreData(context: context)
        object.id = tracker.id
        object.name = tracker.name
        object.emoji = tracker.emoji
        object.colorHex = tracker.color.hexString
        object.schedule = tracker.schedule?.storedValue
        object.category = category
        try context.save()
    }

    func tracker(with id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func fetchOrCreateCategory(title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        if let category = try context.fetch(request).first {
            return category
        }
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        return category
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate()
    }
}

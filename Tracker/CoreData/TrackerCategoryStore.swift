import CoreData

@objc(TrackerCategoryCoreData)
final class TrackerCategoryCoreData: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var trackers: NSSet
}

extension TrackerCategoryCoreData {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TrackerCategoryCoreData> {
        NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    }

    func toCategory() -> TrackerCategory {
        TrackerCategory(
            title: title,
            trackers: (trackers.allObjects as? [TrackerCoreData] ?? []).map { $0.toTracker() }
        )
    }
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: StoreDelegate?

    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
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

    func fetchCategories() -> [TrackerCategory] {
        fetchedResultsController.fetchedObjects?.map { $0.toCategory() } ?? []
    }

    func add(title: String) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", trimmedTitle)
        request.fetchLimit = 1
        if try context.fetch(request).first != nil {
            return
        }

        let category = TrackerCategoryCoreData(context: context)
        category.title = trimmedTitle
        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate()
    }
}

import CoreData

@objc(TrackerRecordCoreData)
final class TrackerRecordCoreData: NSManagedObject {
    @NSManaged var date: Date
    @NSManaged var tracker: TrackerCoreData
}

extension TrackerRecordCoreData {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }

    func toRecord() -> TrackerRecord {
        TrackerRecord(trackerId: tracker.id, date: date)
    }
}

final class TrackerRecordStore: NSObject {
    weak var delegate: StoreDelegate?

    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
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

    func fetchRecords() -> [TrackerRecord] {
        fetchedResultsController.fetchedObjects?.map { $0.toRecord() } ?? []
    }

    func add(_ record: TrackerRecord, tracker: TrackerCoreData) throws {
        let object = TrackerRecordCoreData(context: context)
        object.date = record.date
        object.tracker = tracker
        try context.save()
    }

    func delete(trackerId: UUID, on date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerId as NSUUID)
        let records = try context.fetch(request).filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
        records.forEach { context.delete($0) }
        try context.save()
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate()
    }
}

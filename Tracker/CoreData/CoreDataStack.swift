import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack(
        inMemory: ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    )

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init(modelName: String = "Tracker", inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: modelName)
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Не удалось загрузить хранилище Core Data: \(error)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            assertionFailure("Не удалось сохранить контекст: \(error)")
        }
    }
}

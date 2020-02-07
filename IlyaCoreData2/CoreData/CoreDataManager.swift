import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init () {}
    var viewContext: NSManagedObjectContext? {
        return persistentContainer.viewContext
    }
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "IlyaCoreData2")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func getItems<T: NSFetchRequestResult>(predicate: NSPredicate? = nil) -> [T] {
        var items = [T]()
        let typeName = String(describing: T.self)
        let request = NSFetchRequest<T>(entityName: typeName)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            guard let result = try viewContext?.fetch(request) else {
                return []
            }
            if !result.isEmpty {
                for item in result {
                    items.append(item)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return items
    }

    func getLectors () -> [Lector] {
        return getItems()
    }

    func getStudents () -> [Student] {
        return getItems()
    }

    func getHomework () -> [Homework] {
        return getItems()
    }

    func getLections () -> [Lection] {
        return getItems()
    }

    func getMarks (student: Student?) -> [Mark] {
        if let student = student {
            let predicate = NSPredicate(format: "student == %@", student)
            return getItems(predicate: predicate)
        }

        return getItems()
    }
}

//
//  Persistence.swift
//  test
//
//  Created by Philipp on 13.12.21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static func NewDog(vc: NSManagedObjectContext, i: Int) -> Dog {
        let newItem = Dog(context: vc)
        newItem.name = "name \(i)"
        newItem.activity_hours = Int16(i + 1)
        newItem.typus = DogSize.medium.rawValue
        do {
            try newItem.birthdate = Date("2020-11-08T21:25:11Z", strategy: .iso8601)
            newItem.id = UUID()
            newItem.is_nautered = i % 2 == 0
            newItem.is_old = i % 6 == 0
            
            newItem.weight = MeasurementData(context: vc)
            newItem.weight?.id = UUID()
            newItem.weight?.value = 23.23
            newItem.weight?.symbol = "kg"
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            
        }
        return newItem
    }
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for i in 0..<10 {
            let _ = NewDog(vc: viewContext, i: i)
            
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "dog")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
                
            }
            
            
        })
    }
}

class Fetcher<T:NSManagedObject>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var data: [T] = []
    private let controller: NSFetchedResultsController<T>
    
    let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext, basefetchRequest:NSFetchRequest<T>, sortKey: String = "name") {
        let ft = basefetchRequest
        ft.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: true)]
        controller = NSFetchedResultsController(fetchRequest: ft,
                                                managedObjectContext: context,
                                                sectionNameKeyPath: nil, cacheName: nil)
        self.viewContext = context
        super.init()
        controller.delegate = self
        reload()
    }
    
    func reload() {
        do {
            try controller.performFetch()
            data = controller.fetchedObjects ?? []
        } catch {
            print("failed to fetch items!")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let nJodData = controller.fetchedObjects as? [T]
        else { return }
        
        data = nJodData
    }
    
    func delete<A:NSManagedObject>(_ t: A) {
        viewContext.delete(t)
        let _ = save()
    }
    
    func save() -> Bool {
        do {
            try viewContext.save()
            return true
        } catch {
            print("ignoring error while saving: \(error)")
            return false
        }
    }
    
    func withConext<A>(f: (NSManagedObjectContext) -> A) -> A{
        return f(viewContext)
    }
    
    
}


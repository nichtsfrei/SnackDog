//
//  Persistence.swift
//  test
//
//  Created by Philipp on 13.12.21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static func ExtendDog(newItem: Dog, i: Int) {
        newItem.name = "name \(i)"
        newItem.activity_hours = Int16(i + 1)
        newItem.size = Int16(i % 3)
        do {
            try newItem.birthdate = Date("2020-11-08T21:25:11Z", strategy: .iso8601)
            newItem.id = UUID()
            newItem.is_nautered = i % 2 == 0
            newItem.is_old = i % 6 == 0
            newItem.jod = 631
            newItem.jod_unit = Int16(bcd_micro_gram.rawValue)
            newItem.jod_per = 1
            newItem.jod_per_unit = Int16(bcd_kilo_gram.rawValue)
            newItem.weight = 23.00
            newItem.weight_unit = Int16(bcd_kilo_gram.rawValue)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            
        }
    }
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newItem = Dog(context: viewContext)
            ExtendDog(newItem: newItem, i: i)
            
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

class DogFetcher: NSObject, ObservableObject {
    
    @Published var dogs: [Dog] = []
    private let dogController: NSFetchedResultsController<Dog>
    
    init(managedObjectContext: NSManagedObjectContext) {
        let ft = Dog.fetchRequest()
        ft.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        dogController = NSFetchedResultsController(fetchRequest: ft,
                                                   managedObjectContext: managedObjectContext,
                                                   sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        dogController.delegate = self
        
        reload()
    }
    
    func reload() {
        do {
            try dogController.performFetch()
            
            dogs = dogController.fetchedObjects ?? []
        } catch {
            print("failed to fetch items!")
        }
    }
    
}

class DogManipulator {
    
    let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func toDog(dog: EDog) -> Dog {
        let toSave = Dog(context: viewContext)
        toSave.id = dog.id
        toSave.name = dog.name
        toSave.jod = dog.jod.value
        toSave.jod_unit = dog.jod.unit.toBCDUnit()
        toSave.jod_per = dog.jodPer.value
        toSave.jod_per_unit = dog.jodPer.unit.toBCDUnit()
        toSave.activity_hours = dog.activityHours
        toSave.weight = dog.weight.value
        toSave.weight_unit = dog.weight.unit.toBCDUnit()
        toSave.birthdate = dog.birthDate
        toSave.size = Int16(dog.size.rawValue)
        toSave.is_old = dog.isOld
        toSave.is_nautered = dog.isNautered
        return toSave
    }
    
    
    func remove(dog: Dog) -> Bool {
        viewContext.delete(dog)
        return save()
    }
    
    func put(dog: EDog) -> Bool {
        let _ = toDog(dog: dog)
        return save()
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
}

extension DogFetcher: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    guard let nDogs = controller.fetchedObjects as? [Dog]
      else { return }

    dogs = nDogs
  }
}

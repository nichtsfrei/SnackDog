//
//  SnackDogApp.swift
//  SnackDog
//
//  Created by Philipp on 23.12.21.
//

import SwiftUI

@main
struct SnackDogApp: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject var shared: Shared
    
    
    init() {
        let vc = persistenceController.container.viewContext
        
        let shared = Shared(
            fetcher: Fetcher<Dog>(managedObjectContext: vc, basefetchRequest: Dog.fetchRequest()),
            manipulator: DogManipulator(context: vc)
        )
        self._shared = StateObject(wrappedValue: shared)
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(refresh: shared)
        }
    }
}

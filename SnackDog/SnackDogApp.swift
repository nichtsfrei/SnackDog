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
    
    @StateObject var dogStorage: DogFetcher
    @StateObject var shared: Shared
    
    
    init() {
        let vc = persistenceController.container.viewContext
        let storage = DogFetcher(managedObjectContext: vc)
        self._dogStorage = StateObject(wrappedValue: storage)
        let shared = Shared(
            fetcher: DogFetcher(managedObjectContext: vc),
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

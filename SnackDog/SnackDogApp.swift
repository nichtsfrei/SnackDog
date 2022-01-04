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
    
    @StateObject
    var algaeFetcher = Fetcher<JodData>(
        context: PersistenceController.shared.container.viewContext,
        basefetchRequest: JodData.fetchRequest()
    )
    
    @StateObject
    var dogFetcher = Fetcher<Dog>(
        context: PersistenceController.shared.container.viewContext,
        basefetchRequest: Dog.fetchRequest()
    )
    init() {
       
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(algaeFetcher)
                .environmentObject(dogFetcher)
        }
    }
}

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
    
    
    
    init() {
       
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

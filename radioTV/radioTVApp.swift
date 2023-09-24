//
//  radioTVApp.swift
//  radioTV
//
//  Created by shay moreno on 22/09/2023.
//

import SwiftUI

@main
struct radioTVApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

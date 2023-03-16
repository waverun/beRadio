//
//  beRadioApp.swift
//  beRadio
//
//  Created by Shay  on 16/03/2023.
//

import SwiftUI

@main
struct beRadioApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

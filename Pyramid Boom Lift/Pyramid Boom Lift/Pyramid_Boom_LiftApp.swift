//
//  Pyramid_Boom_LiftApp.swift
//  Pyramid Boom Lift
//
//  Created by David Nishimoto on 10/11/26.
//

import SwiftUI
import CoreData

@main
struct Pyramid_Boom_LiftApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

//
//  SplitInApp.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import SwiftUI
import SwiftData

@main
struct SplitInApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(SharedModelContainer.shared)
    }
}
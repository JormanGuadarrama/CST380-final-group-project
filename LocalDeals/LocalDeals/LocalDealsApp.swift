//
//  LocalDealsApp.swift
//  LocalDeals
//
//  Created by Kevin Crapo on 4/12/26.
//

import SwiftUI
import FirebaseCore

@main
struct LocalDealsApp: App {
    @State private var dealManager: DealManager

    init() {
        FirebaseApp.configure()
        dealManager = DealManager()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(dealManager)
        }
    }
}

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
    init() { 
          FirebaseApp.configure()
      }
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

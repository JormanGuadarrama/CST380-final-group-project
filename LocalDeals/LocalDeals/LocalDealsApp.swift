import SwiftUI
import FirebaseCore

@main
struct LocalDealsApp: App {
    @State private var dealManager: DealManager
    @State private var authManager: AuthManager

    init() {
        FirebaseApp.configure()
        authManager = AuthManager()
        dealManager = DealManager()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.user != nil {
                MainTabView()
                    .environment(dealManager)
                    .environment(authManager)
            } else {
                NavigationStack {
                    LoginView()
                }
                .environment(authManager)
            }
        }
    }
}

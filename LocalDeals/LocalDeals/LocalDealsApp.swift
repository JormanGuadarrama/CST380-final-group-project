import SwiftUI
import FirebaseCore
import FirebaseAuth
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
            Group {
                if authManager.firebaseUser != nil {
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
            .task(id: authManager.firebaseUser?.uid) {
                dealManager.handleAuthChange(userID: authManager.userID)
            }
        }
    }
}

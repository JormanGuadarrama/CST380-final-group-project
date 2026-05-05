import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct LocalDealsApp: App {
    @State private var dealManager: DealManager
    @State private var authManager: AuthManager
    @State private var locationManager: LocationManager
    @State private var notificationManager: NotificationManager

    init() {
        FirebaseApp.configure()
        authManager = AuthManager()
        dealManager = DealManager()
        locationManager = LocationManager.shared
        notificationManager = NotificationManager.shared
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.firebaseUser != nil {
                    MainTabView()
                        .environment(dealManager)
                        .environment(authManager)
                        .environment(locationManager)
                } else {
                    NavigationStack {
                        LoginView()
                    }
                    .environment(authManager)
                    .environment(locationManager)
                }
            }
            .task(id: authManager.firebaseUser?.uid) {
                dealManager.handleAuthChange(userID: authManager.userID)

                if authManager.firebaseUser != nil {
                    locationManager.requestPermission()
                    locationManager.startUpdating()
                    await notificationManager.requestPermission()
                    await dealManager.seedMockDealsIfNeeded()
                } else {
                    locationManager.stopUpdating()
                }
            }
        }
    }
}

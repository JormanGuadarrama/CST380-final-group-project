import SwiftUI

struct MainTabView: View {
    @Environment(DealManager.self) var dealManager
    @Environment(AuthManager.self) var authManager

    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(0)

            AddDealView {
                print("[MainTabView] AddDealView finished from tab. Switching to Map tab.")
                selectedTab = 0
            }
            .tabItem {
                Label("Add Deal", systemImage: "plus")
            }
            .tag(1)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainTabView()
        .environment(DealManager(isMocked: true))
        .environment(AuthManager(isMocked: true))
}

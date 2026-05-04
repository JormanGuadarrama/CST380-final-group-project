import SwiftUI

struct ProfileView: View {
    @Environment(AuthManager.self) var authManager

    @AppStorage("nearbyDealRadiusMiles") private var nearbyDealRadiusMiles = 5

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if let user = authManager.user {
                        Text(user.email)
                            .font(.subheadline)

                        Text("Username: \(user.username)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Provider: \(user.provider)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if let email = authManager.userEmail {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Button("Sign Out", role: .destructive) {
                        authManager.signOut()
                    }
                }

                Section("Nearby Settings") {
                    Stepper(value: $nearbyDealRadiusMiles, in: 1...25, step: 1) {
                        Text("Nearby radius: \(nearbyDealRadiusMiles) miles")
                    }

                    Text("Nearby deals use this radius in 1-mile increments.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthManager(isMocked: true))
}

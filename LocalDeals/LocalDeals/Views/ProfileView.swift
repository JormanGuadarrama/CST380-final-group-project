import SwiftUI

struct ProfileView: View {
    @Environment(DealManager.self) var dealManager
    @Environment(AuthManager.self) var authManager

    var savedDeals: [Deal] { dealManager.savedDeals }

    var body: some View {
        NavigationStack {
            List {
                if let email = authManager.userEmail {
                    Section("Account") {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button("Sign Out", role: .destructive) {
                            authManager.signOut()
                        }
                    }
                }

                Section("Saved Deals") {
                    if savedDeals.isEmpty {
                        Text("No saved deals yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(savedDeals) { deal in
                            DealRow(deal: deal)
                        }
                    }
                }

                Section("Submitted Deals") {
                    if dealManager.deals.isEmpty {
                        Text("No submitted deals yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(dealManager.deals) { deal in
                            DealRow(deal: deal)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

private struct DealRow: View {
    let deal: Deal

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(deal.title)
                .font(.headline)

            Text(deal.businessName)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(deal.expiration.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileView()
        .environment(DealManager(isMocked: true))
        .environment(AuthManager(isMocked: true))
}

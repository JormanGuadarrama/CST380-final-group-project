import SwiftUI

struct ProfileView: View {
    @Environment(DealManager.self) var dealManager
    @Environment(AuthManager.self) var authManager

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

                Section("Saved Deals") {
                    if dealManager.savedDeals.isEmpty {
                        Text("No saved deals yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(dealManager.savedDeals) { deal in
                            DealRow(deal: deal)
                        }
                    }
                }

                Section("Submitted Deals") {
                    let submitted = dealManager.submittedDeals(for: authManager.userID)

                    if submitted.isEmpty {
                        Text("No submitted deals yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(submitted) { deal in
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

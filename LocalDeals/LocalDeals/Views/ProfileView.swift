//
//  ProfileView.swift
//  LocalDeals
//
//  Placeholder lists for saved deals and submitted deals.
//

import SwiftUI

struct ProfileView: View {
    // TODO: wire up to authenticated user (#11, #19) and saved/submitted deals (#12)
    @State private var savedDeals: [Deal] = []
    @State private var submittedDeals: [Deal] = []

    var body: some View {
        NavigationStack {
            List {
                Section("Saved Deals") {
                    if savedDeals.isEmpty {
                        Text("No saved deals yet.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(savedDeals) { deal in
                            NavigationLink(destination: DealDetailView(deal: deal)) {
                                DealRow(deal: deal)
                            }
                        }
                    }
                }

                Section("Submitted Deals") {
                    if submittedDeals.isEmpty {
                        Text("You haven't submitted any deals yet.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(submittedDeals) { deal in
                            NavigationLink(destination: DealDetailView(deal: deal)) {
                                DealRow(deal: deal)
                            }
                        }
                    }
                }

                Section {
                    NavigationLink("Sign In / Register") {
                        LoginView()
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
            Text(deal.title).font(.headline)
            Text(deal.businessName).font(.subheadline).foregroundColor(.secondary)
            Text(deal.expiration).font(.caption).foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileView()
}

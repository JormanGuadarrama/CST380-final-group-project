//
//  DealDetailView.swift
//  LocalDeals
//
//  Detail card layout showing store name, discount, and expiration.
//

import SwiftUI

struct DealDetailView: View {
    let deal: Deal

    @Environment(DealManager.self) var dealManager
    @Environment(AuthManager.self) var authManager

    private var formattedExpiration: String {
        deal.expiration.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(deal.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Label(deal.businessName, systemImage: "storefront")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.accentColor.opacity(0.12))

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        InfoPill(icon: "tag", text: deal.discountType)
                        InfoPill(icon: "clock", text: formattedExpiration)
                        InfoPill(icon: "location", text: "— mi")
                    }

                    Text("Details")
                        .font(.headline)

                    Text(deal.description.isEmpty ? "No additional details." : deal.description)
                        .font(.body)

                    Text("Posted by: \(deal.createdByEmail)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 20)

                    Button {
                        guard let userID = authManager.userID else { return }

                        Task {
                            await dealManager.toggleSave(deal: deal, userID: userID)
                        }
                    } label: {
                        Label(
                            dealManager.isSaved(deal) ? "Remove Saved Deal" : "Save Deal",
                            systemImage: dealManager.isSaved(deal) ? "bookmark.fill" : "bookmark"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Deal Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InfoPill: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(20)
    }
}

#Preview {
    NavigationStack {
        DealDetailView(deal: Deal.mockedDeals[0])
            .environment(DealManager(isMocked: true))
            .environment(AuthManager(isMocked: true))
    }
}

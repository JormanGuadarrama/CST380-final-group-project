//
//  DealDetailView.swift
//  LocalDeals
//
//  Detail card layout showing store name, discount, and expiration.
//

import SwiftUI
import FirebaseFirestore

struct DealDetailView: View {
    let deal: Deal
    @Environment(DealManager.self) var dealManager

    private var formattedExpiration: String {
        deal.expiration.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(deal.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Label(deal.businessName, systemImage: "storefront")
                    .font(.title3)
                    .foregroundColor(.secondary)

                Divider()

                Label(deal.discountType, systemImage: "tag")
                    .font(.subheadline)

                Label(formattedExpiration, systemImage: "clock")
                    .font(.subheadline)

                Label("— mi away · — min drive", systemImage: "location")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Divider()

                Text("Details")
                    .font(.headline)

                Text(deal.description.isEmpty ? "No additional details." : deal.description)
                    .font(.body)

                Spacer(minLength: 20)

                Button(action: { dealManager.toggleSave(deal) }) {
                    let saved = dealManager.isSaved(deal)
                    Label(saved ? "Saved" : "Save Deal",
                          systemImage: saved ? "bookmark.fill" : "bookmark")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(saved ? 0.25 : 0.15))
                        .foregroundColor(.accentColor)
                        .cornerRadius(10)
                        .animation(.easeInOut(duration: 0.2), value: saved)
                }
            }
            .padding()
        }
        .navigationTitle("Deal Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DealDetailView(
        deal: Deal(
            id: UUID().uuidString,
            title: "$5 Off Margarita Flights",
            businessName: "The Brass Tap",
            description: "$5 off margarita flights every Monday night.",
            discountType: "Dollar Off",
            expiration: Date(),
            imageUrl: "",
            location: GeoPoint(latitude: 36.664856, longitude: -121.811935),
            votes: 0
        )
    )
    .environment(DealManager(isMocked: true))
}

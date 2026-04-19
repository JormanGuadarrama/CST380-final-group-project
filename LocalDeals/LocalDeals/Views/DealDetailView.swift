//
//  DealDetailView.swift
//  LocalDeals
//
//  Placeholder card layout showing store name, discount, and expiration.
//

import SwiftUI
import CoreLocation

struct DealDetailView: View {
    let deal: Deal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                    // Discount / title — visually prioritized
                    Text(deal.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    // Store name
                    Label(deal.businessName, systemImage: "storefront")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Divider()

                    // Expiration
                    Label(deal.expiration, systemImage: "clock")
                        .font(.subheadline)

                    // Distance / ETA placeholder (TODO: wire up location services)
                    Label("— mi away · — min drive", systemImage: "location")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Divider()

                    // Description
                    Text("Details")
                        .font(.headline)
                    Text(deal.description.isEmpty ? "No additional details." : deal.description)
                        .font(.body)

                    Spacer(minLength: 20)

                    // Save / bookmark placeholder (TODO: #12)
                    Button(action: { /* TODO: save deal */ }) {
                        Label("Save Deal", systemImage: "bookmark")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundColor(.accentColor)
                            .cornerRadius(10)
                    }
            }
            .padding()
        }
        .navigationTitle("Deal Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DealDetailView(deal: Deal(
        title: "$5 Off Margarita Flights",
        businessName: "The Brass Tap",
        description: "$5 off margarita flights every Monday night.",
        expiration: "Every Monday",
        coordinate: CLLocationCoordinate2D(latitude: 36.664856, longitude: -121.811935)
    ))
}

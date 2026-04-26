//
//  DealDetailView.swift
//  LocalDeals
//

import SwiftUI
import CoreLocation

struct DealDetailView: View {
    let deal: Deal

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero card — discount visually prioritized
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
                    // Quick-scan info row
                    HStack(spacing: 10) {
                        InfoPill(icon: "clock", text: deal.expiration)
                        InfoPill(icon: "location", text: "— mi")
                        InfoPill(icon: "car", text: "— min drive")
                    }

                    Divider()

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
        DealDetailView(deal: Deal(
            title: "$5 Off Margarita Flights",
            businessName: "The Brass Tap",
            description: "$5 off margarita flights every Monday night.",
            expiration: "Every Monday",
            coordinate: CLLocationCoordinate2D(latitude: 36.664856, longitude: -121.811935)
        ))
    }
}

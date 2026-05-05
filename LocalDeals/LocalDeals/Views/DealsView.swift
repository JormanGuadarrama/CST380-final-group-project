import SwiftUI
import CoreLocation
import FirebaseFirestoreInternal

struct DealsView: View {
    @Environment(DealManager.self) var dealManager
    @Environment(AuthManager.self) var authManager

    @State private var locationManager = LocationManager.shared

    @AppStorage("nearbyDealRadiusMiles") private var nearbyDealRadiusMiles = 5

    private var isInitialLoadInProgress: Bool {
        dealManager.isInitialProfileLoadInProgress(for: authManager.userID)
    }

    private var submittedDeals: [Deal] {
        dealManager.submittedDeals(for: authManager.userID)
    }

    private var nearbyDeals: [Deal] {
        let excludedIDs = Set(dealManager.savedDeals.map(\.id) + submittedDeals.map(\.id))
        return dealManager.nearbyDeals(
            around: locationManager.currentLocation,
            radiusMiles: Double(nearbyDealRadiusMiles),
            excluding: excludedIDs
        )
    }

    private var expiredDeals: [Deal] {
        Array(Set(dealManager.savedDeals + submittedDeals)).filter { $0.isExpired }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isInitialLoadInProgress {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading your deals...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section("Saved Deals") {
                            if dealManager.savedDeals.isEmpty {
                                Text("No saved deals yet.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(dealManager.savedDeals) { deal in
                                    DealRow(deal: deal, distanceText: nil)
                                }
                            }
                        }

                        Section("Nearby Deals") {
                            if locationManager.currentLocation == nil {
                                Text("Turn on location to see nearby deals.")
                                    .foregroundStyle(.secondary)
                            } else if nearbyDeals.isEmpty {
                                Text("No nearby deals within \(nearbyDealRadiusMiles) miles.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(nearbyDeals) { deal in
                                    DealRow(
                                        deal: deal,
                                        distanceText: distanceText(
                                            for: deal,
                                            currentLocation: locationManager.currentLocation
                                        )
                                    )
                                }
                            }
                        }

                        Section("Submitted Deals") {
                            if submittedDeals.isEmpty {
                                Text("No submitted deals yet.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(submittedDeals) { deal in
                                    DealRow(deal: deal, distanceText: nil)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Deals")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        Task {
                            await dealManager.archiveExpiredDeals(for: authManager.userID)
                        }
                    }
                    .disabled(expiredDeals.isEmpty)
                }
            }
            .onAppear {
                locationManager.requestPermission()
                locationManager.startUpdating()
            }
            .onDisappear {
                locationManager.stopUpdating()
            }
        }
    }
}

private struct DealRow: View {
    let deal: Deal
    let distanceText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
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

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 4) {
                    if let distanceText {
                        Text(distanceText)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    if deal.isExpired {
                        Text("Expired")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.9), in: Capsule())
                    }
                }
            }

            DealVoteControls(deal: deal, compact: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private func distanceText(for deal: Deal, currentLocation: CLLocation?) -> String? {
    guard let currentLocation else { return nil }

    let dealLocation = CLLocation(
        latitude: deal.location.latitude,
        longitude: deal.location.longitude
    )
    let distanceMiles = currentLocation.distance(from: dealLocation) / 1609.34

    return String(format: "%.1f mi away", distanceMiles)
}

#Preview {
    DealsView()
        .environment(DealManager(isMocked: true))
        .environment(AuthManager(isMocked: true))
}

//
//  MapView.swift
//  LocalDeals
//
//  Map (Home) screen — displays deals fetched from Firestore.
//

import SwiftUI
import MapKit
import FirebaseFirestoreInternal

struct MapView: View {
    @Environment(DealManager.self) var dealManager

    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.665389, longitude: -121.811307),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    @State private var showAddDeal = false
    @State private var selectedDeal: Deal?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Map(position: $position) {
                    ForEach(dealManager.deals) { deal in
                        Annotation(
                            deal.businessName,
                            coordinate: CLLocationCoordinate2D(
                                latitude: deal.location.latitude,
                                longitude: deal.location.longitude
                            )
                        ) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(.red)
                                .font(.title)
                                .onTapGesture {
                                    selectedDeal = deal
                                }
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                Button(action: { showAddDeal = true }) {
                    Label("Add Deal", systemImage: "plus")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                }
                .padding()
            }
            .navigationTitle("Local Deals")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddDeal) {
                AddDealView()
            }
            .sheet(item: $selectedDeal) { deal in
                DealDetailView(deal: deal)
            }
        }
    }
}

#Preview {
    MapView()
        .environment(DealManager(isMocked: true))
}

//
//  MapView.swift
//  LocalDeals
//
//  Map (Home) screen — empty map view with "+Add Deal" button placeholder.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.665389, longitude: -121.811307),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    @State private var showAddDeal = false
    @State private var selectedDeal: Deal?

    // TODO: Replace with deals fetched from backend (#6, #16, #17)
    let sampleDeals: [Deal] = [
        Deal(
            title: "$5 Off Margarita Flights",
            businessName: "The Brass Tap",
            description: "$5 off margarita flights",
            expiration: "Every Monday",
            coordinate: CLLocationCoordinate2D(latitude: 36.664856, longitude: -121.811935)
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Map(position: $position) {
                    ForEach(sampleDeals) { deal in
                        Annotation(deal.businessName, coordinate: deal.coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
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
                        .foregroundColor(.white)
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
}

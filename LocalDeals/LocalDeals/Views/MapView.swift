import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestoreInternal

struct MapView: View {
    @Environment(DealManager.self) var dealManager

    @State private var locationManager = LocationManager()
    @State private var hasCenteredOnUser = false

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.665389, longitude: -121.811307),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    @State private var showAddDeal = false
    @State private var selectedDeal: Deal?

    private var validDeals: [Deal] {
        dealManager.deals.filter { $0.expiration >= Date() }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Map(position: $position) {
                    ForEach(validDeals) { deal in
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

                    if let currentLocation = locationManager.currentLocation {
                        Annotation("You", coordinate: currentLocation.coordinate) {
                            Image(systemName: "location.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.title2)
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .onChange(of: locationManager.currentLocation) { _, newLocation in
                    guard let newLocation, !hasCenteredOnUser else { return }

                    position = .region(
                        MKCoordinateRegion(
                            center: newLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                    )
                    hasCenteredOnUser = true
                }

                VStack(alignment: .trailing, spacing: 12) {
                    Button {
                        if let currentLocation = locationManager.currentLocation {
                            position = .region(
                                MKCoordinateRegion(
                                    center: currentLocation.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                )
                            )
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.headline)
                            .padding(12)
                            .background(.thinMaterial)
                            .clipShape(Circle())
                    }

                    Button {
                        showAddDeal = true
                    } label: {
                        Label("Add Deal", systemImage: "plus")
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                    }
                }
                .padding()
            }
            .navigationTitle("Local Deals")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationManager.requestPermission()
                locationManager.startUpdating()
            }
            .sheet(isPresented: $showAddDeal) {
                AddDealView()
                    .environment(locationManager)
            }
            .sheet(item: $selectedDeal) { deal in
                NavigationStack {
                    DealDetailView(deal: deal)
                }
            }
        }
    }
}

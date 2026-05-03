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
                                    print("[MapView] Selected deal: \(deal.title)")
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
                .overlay {
                    if dealManager.isInitialDealsLoadInProgress {
                        ProgressView("Loading deals...")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 8)
                    }
                }

                VStack(alignment: .trailing, spacing: 12) {
                    Button {
                        if let currentLocation = locationManager.currentLocation {
                            print("[MapView] Centering on user location")
                            position = .region(
                                MKCoordinateRegion(
                                    center: currentLocation.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                )
                            )
                        } else {
                            print("[MapView] Center button tapped, but currentLocation is nil")
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.headline)
                            .padding(12)
                            .background(.thinMaterial)
                            .clipShape(Circle())
                    }

                    Button {
                        print("[MapView] Opening AddDealView sheet")
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
                print("[MapView] onAppear. Requesting location permission and starting updates.")
                locationManager.requestPermission()
                locationManager.startUpdating()
            }
            .onChange(of: locationManager.currentLocation) { _, newLocation in
                guard let newLocation, !hasCenteredOnUser else { return }

                print("[MapView] First location received. Centering map.")

                position = .region(
                    MKCoordinateRegion(
                        center: newLocation.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                )
                hasCenteredOnUser = true
            }
            .sheet(isPresented: $showAddDeal) {
                NavigationStack {
                    AddDealView {
                        print("[MapView] AddDealView finished. Closing sheet.")
                        showAddDeal = false
                    }
                    .environment(locationManager)
                }
            }
            .sheet(item: $selectedDeal) { deal in
                NavigationStack {
                    DealDetailView(deal: deal)
                }
            }
        }
    }
}

#Preview {
    MapView()
        .environment(DealManager(isMocked: true))
}
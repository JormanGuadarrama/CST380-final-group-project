import SwiftUI
import MapKit
import CoreLocation

struct MapPickerView: View {
    @Environment(LocationManager.self) var locationManager
    @Environment(\.dismiss) private var dismiss

    let onSelect: (CLLocationCoordinate2D) -> Void

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.665389, longitude: -121.811307),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var hasCenteredOnUser = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                MapReader { proxy in
                    Map(position: $position) {
                        if let selectedCoordinate {
                            Annotation("Selected", coordinate: selectedCoordinate) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.title)
                            }
                        }

                        if let userLocation = locationManager.currentLocation {
                            Annotation("You", coordinate: userLocation.coordinate) {
                                Image(systemName: "location.circle.fill")
                                    .foregroundStyle(.blue)
                                    .font(.title2)
                            }
                        }
                    }
                    .onTapGesture { point in
                        if let coordinate = proxy.convert(point, from: .local) {
                            selectedCoordinate = coordinate
                        }
                    }
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
                }

                Button {
                    if let userLocation = locationManager.currentLocation {
                        position = .region(
                            MKCoordinateRegion(
                                center: userLocation.coordinate,
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
                .padding()
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Select") {
                        if let selectedCoordinate {
                            onSelect(selectedCoordinate)
                        }
                        dismiss()
                    }
                    .disabled(selectedCoordinate == nil)
                }
            }
            .onAppear {
                locationManager.requestPermission()
                locationManager.startUpdating()
            }
        }
    }
}

#Preview {
    MapPickerView { _ in }
        .environment(LocationManager())
}

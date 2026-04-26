//
//  MapPickerView.swift
//  LocalDeals
//
//  Created by Rene Reyes on 4/24/26.
//

import SwiftUI
import MapKit

struct MapPickerView: View {
    @Environment(\.dismiss) private var dismiss

    let onLocationPicked: (CLLocationCoordinate2D) -> Void

    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.665389, longitude: -121.811307),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    @State private var selectedCoordinate: CLLocationCoordinate2D?

    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $position) {
                    if let selectedCoordinate {
                        Annotation("Selected Location", coordinate: selectedCoordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .onTapGesture { screenCoordinate in
                    if let coordinate = proxy.convert(screenCoordinate, from: .local) {
                        selectedCoordinate = coordinate
                    }
                }
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
                    Button("Use Location") {
                        if let selectedCoordinate {
                            onLocationPicked(selectedCoordinate)
                            dismiss()
                        }
                    }
                    .disabled(selectedCoordinate == nil)
                }
            }
        }
    }
}

#Preview {
    MapPickerView { _ in }
}

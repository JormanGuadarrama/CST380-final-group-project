//
//  ContentView.swift

import SwiftUI
import MapKit

import SwiftUI
import MapKit


struct ContentView: View {

    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.665389, longitude: -121.811307),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    
    // prepopulating
    let sampleDeals = [
        Deal(
            title: "$5 Off Margarita Flights",
            businessName: "The Brass Tap",
            description: "$5 off margarita flights",
            expiration: "Every Monday",
            coordinate: CLLocationCoordinate2D(
                latitude: 36.664856, // marina location
                longitude: -121.811935
            )
        )
    ]


    var body: some View {
            Map(position: $position) {
                ForEach(sampleDeals) { deal in
                    Annotation(deal.businessName, coordinate: deal.coordinate) {
                        VStack(spacing: 2) {

                            Text(deal.title)
                                .font(.caption2)
                            
                            Text(deal.businessName)
                                .font(.caption2)
                                .bold()
                            Text(deal.expiration)
                                .font(.caption2)
                                .foregroundColor(.gray)

                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                        .padding(5)
                        .background(Color.white)
                        .cornerRadius(6)
                    }
                }
            }
            .ignoresSafeArea()
    }
}


#Preview {
    ContentView()
}

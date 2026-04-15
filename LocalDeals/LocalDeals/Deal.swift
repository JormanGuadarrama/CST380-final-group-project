//
//  Deal.swift
//

import Foundation
import MapKit

struct Deal: Identifiable {
    let id = UUID()
    let title: String
    let businessName: String
    let description: String
    let expiration: String
    let coordinate: CLLocationCoordinate2D
}

import Foundation
import FirebaseFirestore

struct Deal: Hashable, Identifiable {
    let id: String
    let title: String
    let businessName: String
    let description: String
    let discountType: String
    let expiration: Date
    let imageUrl: String
    let location: GeoPoint
    let votes: Int
    let createdByUid: String?
    let createdByEmail: String?
    let createdAt: Date?
}

extension Deal {
    static let mockedDeals: [Deal] = [
        Deal(
            id: "seed_1",
            title: "$5 Off Margarita Flights",
            businessName: "The Brass Tap",
            description: "$5 off margarita flights every Monday night.",
            discountType: "Dollar Off",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 7),
            imageUrl: "",
            location: GeoPoint(latitude: 36.664856, longitude: -121.811935),
            votes: 0,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_2",
            title: "BOGO Burrito",
            businessName: "Chipotle",
            description: "Buy one burrito, get one free after 5 PM.",
            discountType: "BOGO",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 5),
            imageUrl: "",
            location: GeoPoint(latitude: 36.668200, longitude: -121.809500),
            votes: 3,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_3",
            title: "20% Off Coffee Drinks",
            businessName: "Starbucks",
            description: "20% off any handcrafted drink.",
            discountType: "Percent Off",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 3),
            imageUrl: "",
            location: GeoPoint(latitude: 36.666100, longitude: -121.812700),
            votes: 1,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        )
    ]
}

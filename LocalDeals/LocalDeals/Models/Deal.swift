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
    let createdByUid: String
    let createdByEmail: String
    let createdAt: Date?
}

extension Deal {
    static let mockedDeals: [Deal] = [
        Deal(
            id: UUID().uuidString,
            title: "$5 Off Margarita Flights",
            businessName: "The Brass Tap",
            description: "$5 off margarita flights every Monday night.",
            discountType: "Dollar Off",
            expiration: Date(),
            imageUrl: "",
            location: GeoPoint(latitude: 36.664856, longitude: -121.811935),
            votes: 0,
            createdByUid: "mock-user-id",
            createdByEmail: "preview@localdeals.com",
            createdAt: Date()
        ),
        Deal(
            id: UUID().uuidString,
            title: "BOGO Burrito",
            businessName: "Chipotle",
            description: "Buy one burrito, get one free after 5 PM.",
            discountType: "BOGO",
            expiration: Date(),
            imageUrl: "",
            location: GeoPoint(latitude: 36.668200, longitude: -121.809500),
            votes: 3,
            createdByUid: "mock-user-id",
            createdByEmail: "preview@localdeals.com",
            createdAt: Date()
        ),
        Deal(
            id: UUID().uuidString,
            title: "20% Off Coffee Drinks",
            businessName: "Starbucks",
            description: "20% off any handcrafted drink.",
            discountType: "Percent Off",
            expiration: Date(),
            imageUrl: "",
            location: GeoPoint(latitude: 36.666100, longitude: -121.812700),
            votes: 1,
            createdByUid: "mock-user-id",
            createdByEmail: "preview@localdeals.com",
            createdAt: Date()
        )
    ]
}

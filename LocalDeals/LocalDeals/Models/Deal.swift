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

    init(
        id: String,
        title: String,
        businessName: String,
        description: String,
        discountType: String,
        expiration: Date,
        imageUrl: String,
        location: GeoPoint,
        votes: Int = 0,
        createdByUid: String?,
        createdByEmail: String?,
        createdAt: Date?
    ) {
        self.id = id
        self.title = title
        self.businessName = businessName
        self.description = description
        self.discountType = discountType
        self.expiration = expiration
        self.imageUrl = imageUrl
        self.location = location
        self.votes = votes
        self.createdByUid = createdByUid
        self.createdByEmail = createdByEmail
        self.createdAt = createdAt
    }
}

extension Deal {
    var isExpired: Bool {
        expiration < Date()
    }

    static let mockedDeals: [Deal] = [
        Deal(
            id: "seed_1",
            title: "$5 Off Shareables",
            businessName: "The Brass Tap Marina",
            description: "$5 off any appetizer or shareable plate after 4 PM.",
            discountType: "Dollar Off",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 45),
            imageUrl: "",
            location: GeoPoint(latitude: 36.665389, longitude: -121.811307),
            votes: 8,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_2",
            title: "BOGO Breakfast Burritos",
            businessName: "Marina Morning Cafe",
            description: "Buy one breakfast burrito, get one free before 11 AM.",
            discountType: "BOGO",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 30),
            imageUrl: "",
            location: GeoPoint(latitude: 36.684930, longitude: -121.802790),
            votes: 6,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_3",
            title: "15% Off Beach Rentals",
            businessName: "Marina Dunes Rentals",
            description: "Get 15% off beach chairs, umbrellas, and picnic gear for the day.",
            discountType: "Percent Off",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 60),
            imageUrl: "",
            location: GeoPoint(latitude: 36.683700, longitude: -121.807700),
            votes: 4,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_4",
            title: "$3 Off Coffee Flights",
            businessName: "Cannery Row Coffee House",
            description: "$3 off a sampler flight of iced coffee drinks.",
            discountType: "Dollar Off",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 50),
            imageUrl: "",
            location: GeoPoint(latitude: 36.616500, longitude: -121.900600),
            votes: 10,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_5",
            title: "20% Off Souvenirs",
            businessName: "Cannery Row Gift Stop",
            description: "Take 20% off magnets, postcards, mugs, and local souvenirs.",
            discountType: "Percent Off",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 75),
            imageUrl: "",
            location: GeoPoint(latitude: 36.616500, longitude: -121.900600),
            votes: 2,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_6",
            title: "$10 Off Aquarium Day Bundle",
            businessName: "Bay View Snack Stand",
            description: "$10 off a family snack bundle with drinks and treats.",
            discountType: "Dollar Off",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 90),
            imageUrl: "",
            location: GeoPoint(latitude: 36.618200, longitude: -121.901800),
            votes: 7,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_7",
            title: "Free Chowder Cup With Entree",
            businessName: "Wharfside Seafood Grill",
            description: "Get a free cup of clam chowder with any lunch or dinner entree.",
            discountType: "Free Item",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 40),
            imageUrl: "",
            location: GeoPoint(latitude: 36.604161, longitude: -121.892800),
            votes: 12,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_8",
            title: "25% Off Whale Watching Hoodie",
            businessName: "Old Wharf Outfitters",
            description: "Take 25% off one Monterey whale watching hoodie.",
            discountType: "Percent Off",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 65),
            imageUrl: "",
            location: GeoPoint(latitude: 36.604161, longitude: -121.892800),
            votes: 3,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_9",
            title: "BOGO Smoothies",
            businessName: "Del Monte Smoothie Bar",
            description: "Buy one smoothie, get one of equal or lesser value free.",
            discountType: "BOGO",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 55),
            imageUrl: "",
            location: GeoPoint(latitude: 36.5846388, longitude: -121.8973477),
            votes: 9,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_10",
            title: "$8 Off Movie Night Combo",
            businessName: "Monterey Cinema Snacks",
            description: "$8 off a large popcorn and two drink combo after 6 PM.",
            discountType: "Dollar Off",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 85),
            imageUrl: "",
            location: GeoPoint(latitude: 36.5846388, longitude: -121.8973477),
            votes: 5,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_11",
            title: "Kids Eat Free",
            businessName: "Pearl Street Family Diner",
            description: "One free kids meal with purchase of an adult entree.",
            discountType: "Free Item",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 35),
            imageUrl: "",
            location: GeoPoint(latitude: 36.597778, longitude: -121.886111),
            votes: 11,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        ),
        Deal(
            id: "seed_12",
            title: "10% Off Historic Walking Tour",
            businessName: "Old Monterey Tour Co.",
            description: "Save 10% on a guided historic walking tour of downtown Monterey.",
            discountType: "Percent Off",
            expiration: Date().addingTimeInterval(60 * 60 * 24 * 70),
            imageUrl: "",
            location: GeoPoint(latitude: 36.602500, longitude: -121.894444),
            votes: 6,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date()
        )
        Deal(
            id: "seed_expired_1",
            title: "Expired: $4 Off Fish Tacos",
            businessName: "Marina Beach Taco Shack",
            description: "This expired test deal gives $4 off any fish taco plate.",
            discountType: "Dollar Off",
            expiration: Date().addingTimeInterval(-60 * 60 * 24 * 7),
            imageUrl: "",
            location: GeoPoint(latitude: 36.684930, longitude: -121.802790),
            votes: 3,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 20)
        ),
        Deal(
            id: "seed_expired_2",
            title: "Expired: 20% Off Coffee",
            businessName: "Seaside Morning Roast",
            description: "This expired test deal gives 20% off any large coffee drink.",
            discountType: "Percent Off",
            expiration: Date().addingTimeInterval(-60 * 60 * 24 * 3),
            imageUrl: "",
            location: GeoPoint(latitude: 36.611070, longitude: -121.851620),
            votes: 5,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 18)
        ),
        Deal(
            id: "seed_expired_3",
            title: "Expired: BOGO Smoothie",
            businessName: "Broadway Smoothie Stop",
            description: "This expired test deal gives one free smoothie with purchase of another.",
            discountType: "BOGO",
            expiration: Date().addingTimeInterval(-60 * 60 * 24 * 12),
            imageUrl: "",
            location: GeoPoint(latitude: 36.609600, longitude: -121.845900),
            votes: 2,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 30)
        ),
        Deal(
            id: "seed_expired_4",
            title: "Expired: Free Garlic Fries",
            businessName: "Sand City Burger Bar",
            description: "This expired test deal gives a free side of garlic fries with any burger.",
            discountType: "Free Item",
            expiration: Date().addingTimeInterval(-60 * 60 * 24 * 1),
            imageUrl: "",
            location: GeoPoint(latitude: 36.617700, longitude: -121.848800),
            votes: 7,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 14)
        ),
        Deal(
            id: "seed_expired_5",
            title: "Expired: $6 Off Lunch Combo",
            businessName: "Marina Village Deli",
            description: "This expired test deal gives $6 off a sandwich, chips, and drink lunch combo.",
            discountType: "Dollar Off",
            expiration: Date().addingTimeInterval(-60 * 60 * 24 * 5),
            imageUrl: "",
            location: GeoPoint(latitude: 36.681200, longitude: -121.787500),
            votes: 4,
            createdByUid: "seed-data",
            createdByEmail: "seed@localdeals.app",
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 22)
        )
    ]
}

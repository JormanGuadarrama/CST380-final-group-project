import Foundation
import FirebaseFirestore
import Observation

@Observable
class DealManager {
    var deals: [Deal] = []
    private(set) var savedDealIDs: Set<String>

    private let database = Firestore.firestore()
    private let savedDealsKey = "savedDealIDs"

    var savedDeals: [Deal] {
        deals.filter { savedDealIDs.contains($0.id) }
    }

    init(isMocked: Bool = false) {
        let stored = UserDefaults.standard.stringArray(forKey: "savedDealIDs") ?? []
        savedDealIDs = Set(stored)
        if isMocked {
            deals = Deal.mockedDeals
        } else {
            getDeals()
        }
    }

    func isSaved(_ deal: Deal) -> Bool {
        savedDealIDs.contains(deal.id)
    }

    func toggleSave(_ deal: Deal) {
        if savedDealIDs.contains(deal.id) {
            savedDealIDs.remove(deal.id)
        } else {
            savedDealIDs.insert(deal.id)
        }
        UserDefaults.standard.set(Array(savedDealIDs), forKey: savedDealsKey)
    }

    func getDeals() {
        database.collection("deals").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching deal documents: \(String(describing: error))")
                return
            }

            let fetchedDeals: [Deal] = documents.compactMap { document in
                let data = document.data()

                guard
                    let title = data["title"] as? String,
                    let businessName = data["businessName"] as? String,
                    let description = data["description"] as? String,
                    let discountType = data["discountType"] as? String,
                    let expirationTimestamp = data["expiration"] as? Timestamp,
                    let imageUrl = data["imageUrl"] as? String,
                    let location = data["location"] as? GeoPoint
                else {
                    print("Skipping invalid document: \(document.documentID)")
                    return nil
                }

                let votes = data["votes"] as? Int ?? 0

                return Deal(
                    id: document.documentID,
                    title: title,
                    businessName: businessName,
                    description: description,
                    discountType: discountType,
                    expiration: expirationTimestamp.dateValue(),
                    imageUrl: imageUrl,
                    location: location,
                    votes: votes
                )
            }

            self.deals = fetchedDeals
        }
    }

    func addDeal(
        title: String,
        businessName: String,
        description: String,
        discountType: String,
        expiration: Date,
        imageUrl: String = "",
        latitude: Double,
        longitude: Double,
        votes: Int = 0
    ) {
        let data: [String: Any] = [
            "title": title,
            "businessName": businessName,
            "description": description,
            "discountType": discountType,
            "expiration": Timestamp(date: expiration),
            "imageUrl": imageUrl,
            "location": GeoPoint(latitude: latitude, longitude: longitude),
            "votes": votes
        ]

        database.collection("deals").addDocument(data: data) { error in
            if let error = error {
                print("Error adding deal: \(error.localizedDescription)")
            } else {
                print("Deal added successfully")
            }
        }
    }
}

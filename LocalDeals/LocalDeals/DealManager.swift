import Foundation
import FirebaseFirestore
import Observation

@Observable
class DealManager {
    var deals: [Deal] = []

    private let database = Firestore.firestore()

    init(isMocked: Bool = false) {
        if isMocked {
            deals = Deal.mockedDeals
        } else {
            getDeals()
        }
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

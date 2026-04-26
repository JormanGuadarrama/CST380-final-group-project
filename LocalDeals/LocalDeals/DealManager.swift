import Foundation
import FirebaseFirestore
import Observation

@MainActor
@Observable
final class DealManager {
    var deals: [Deal] = []
    private(set) var savedDealIDs: Set<String> = []

    private let database = Firestore.firestore()
    private var dealsListener: ListenerRegistration?
    private var userDealsListener: ListenerRegistration?

    init(isMocked: Bool = false) {
        if isMocked {
            deals = Deal.mockedDeals
            if let first = Deal.mockedDeals.first {
                savedDealIDs = [first.id]
            }
        } else {
            listenForDeals()
        }
    }

    deinit {
        dealsListener?.remove()
        userDealsListener?.remove()
    }

    var savedDeals: [Deal] {
        deals.filter { savedDealIDs.contains($0.id) }
    }

    func submittedDeals(for userID: String?) -> [Deal] {
        guard let userID else { return [] }
        return deals.filter { $0.createdByUid == userID }
    }

    func isSaved(_ deal: Deal) -> Bool {
        savedDealIDs.contains(deal.id)
    }

    func handleAuthChange(userID: String?) {
        userDealsListener?.remove()
        savedDealIDs = []

        guard let userID else { return }

        userDealsListener = database.collection("userDeals")
            .whereField("userId", isEqualTo: userID)
            .whereField("relationType", isEqualTo: "saved")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    print("Error fetching userDeals: \(error.localizedDescription)")
                    return
                }

                let ids = snapshot?.documents.compactMap { $0.data()["dealId"] as? String } ?? []
                self.savedDealIDs = Set(ids)
            }
    }

    private func listenForDeals() {
        dealsListener = database.collection("deals")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self else { return }

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching deals: \(String(describing: error))")
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
                        let location = data["location"] as? GeoPoint,
                        let createdByUid = data["createdByUid"] as? String,
                        let createdByEmail = data["createdByEmail"] as? String
                    else {
                        print("Skipping invalid deal doc: \(document.documentID)")
                        return nil
                    }

                    let votes = data["votes"] as? Int ?? 0
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()

                    return Deal(
                        id: document.documentID,
                        title: title,
                        businessName: businessName,
                        description: description,
                        discountType: discountType,
                        expiration: expirationTimestamp.dateValue(),
                        imageUrl: imageUrl,
                        location: location,
                        votes: votes,
                        createdByUid: createdByUid,
                        createdByEmail: createdByEmail,
                        createdAt: createdAt
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
        createdByUid: String,
        createdByEmail: String
    ) async {
        let dealData: [String: Any] = [
            "title": title,
            "businessName": businessName,
            "description": description,
            "discountType": discountType,
            "expiration": Timestamp(date: expiration),
            "imageUrl": imageUrl,
            "location": GeoPoint(latitude: latitude, longitude: longitude),
            "votes": 0,
            "createdByUid": createdByUid,
            "createdByEmail": createdByEmail,
            "createdAt": Timestamp(date: Date())
        ]

        do {
            let dealRef = try await database.collection("deals").addDocument(data: dealData)

            let relationData: [String: Any] = [
                "userId": createdByUid,
                "dealId": dealRef.documentID,
                "relationType": "created",
                "createdAt": Timestamp(date: Date())
            ]

            try await database.collection("userDeals").addDocument(data: relationData)
        } catch {
            print("Error adding deal: \(error.localizedDescription)")
        }
    }

    func toggleSave(deal: Deal, userID: String) async {
        do {
            let query = try await database.collection("userDeals")
                .whereField("userId", isEqualTo: userID)
                .whereField("dealId", isEqualTo: deal.id)
                .whereField("relationType", isEqualTo: "saved")
                .getDocuments()

            if let existing = query.documents.first {
                try await database.collection("userDeals")
                    .document(existing.documentID)
                    .delete()
            } else {
                let relationData: [String: Any] = [
                    "userId": userID,
                    "dealId": deal.id,
                    "relationType": "saved",
                    "createdAt": Timestamp(date: Date())
                ]

                try await database.collection("userDeals")
                    .addDocument(data: relationData)
            }
        } catch {
            print("Error toggling save: \(error.localizedDescription)")
        }
    }
}

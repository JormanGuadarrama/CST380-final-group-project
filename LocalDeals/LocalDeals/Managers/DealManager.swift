//
//  DealManager.swift
//  LocalDeals
//
//  Created by Kevin Crapo on 4/26/26.
//

import Foundation
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import Observation

@MainActor
@Observable
final class DealManager {
    var deals: [Deal] = []
    private(set) var savedDealIDs: Set<String> = []
    private(set) var isLoadingDeals = true
    private(set) var hasLoadedDeals = false
    private(set) var isLoadingSavedDeals = false
    private(set) var hasLoadedSavedDeals = false
    private(set) var archivedDealIDs: Set<String> = []

    private let database = Firestore.firestore()
    private var dealsListener: ListenerRegistration?
    private var userDealsListener: ListenerRegistration?

    init(isMocked: Bool = false) {
        if isMocked {
            deals = Deal.mockedDeals

            if let first = Deal.mockedDeals.first {
                savedDealIDs = [first.id]
            }

            isLoadingDeals = false
            hasLoadedDeals = true
            isLoadingSavedDeals = false
            hasLoadedSavedDeals = true
            archivedDealIDs = []
        }
    }

    var savedDeals: [Deal] {
        deals.filter { savedDealIDs.contains($0.id) && !archivedDealIDs.contains($0.id) }
    }

    var isInitialDealsLoadInProgress: Bool {
        isLoadingDeals && !hasLoadedDeals
    }

    func isInitialProfileLoadInProgress(for userID: String?) -> Bool {
        if userID == nil {
            return isInitialDealsLoadInProgress
        }

        return (isLoadingDeals && !hasLoadedDeals) || (isLoadingSavedDeals && !hasLoadedSavedDeals)
    }

    func submittedDeals(for userID: String?) -> [Deal] {
        guard let userID else { return [] }
        return deals.filter { $0.createdByUid == userID && !archivedDealIDs.contains($0.id) }
    }

    func nearbyDeals(
        around currentLocation: CLLocation?,
        radiusMiles: Double,
        excluding excludedDealIDs: Set<String> = []
    ) -> [Deal] {
        guard let currentLocation else { return [] }

        let radiusMeters = radiusMiles * 1609.34

        return deals
            .filter { !$0.isExpired }
            .filter { !excludedDealIDs.contains($0.id) }
            .filter { deal in
                let dealLocation = CLLocation(
                    latitude: deal.location.latitude,
                    longitude: deal.location.longitude
                )

                return currentLocation.distance(from: dealLocation) <= radiusMeters
            }
            .sorted {
                let firstDistance = currentLocation.distance(
                    from: CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude)
                )
                let secondDistance = currentLocation.distance(
                    from: CLLocation(latitude: $1.location.latitude, longitude: $1.location.longitude)
                )

                return firstDistance < secondDistance
            }
    }

    func isSaved(_ deal: Deal) -> Bool {
        savedDealIDs.contains(deal.id)
    }

    func handleAuthChange(userID: String?) {
        dealsListener?.remove()
        userDealsListener?.remove()

        deals = []
        savedDealIDs = []
        archivedDealIDs = []

        guard let userID else {
            isLoadingDeals = false
            hasLoadedDeals = true
            isLoadingSavedDeals = false
            hasLoadedSavedDeals = true
            return
        }

        isLoadingDeals = true
        hasLoadedDeals = false
        isLoadingSavedDeals = true
        hasLoadedSavedDeals = false

        listenForDeals()

        userDealsListener = database.collection("userDeals")
            .whereField("userId", isEqualTo: userID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                guard let snapshot else {
                    if let error {
                        print("Error fetching userDeals: \(error.localizedDescription)")
                    }

                    self.isLoadingSavedDeals = false
                    self.hasLoadedSavedDeals = true
                    return
                }

                var savedIDs: Set<String> = []
                var archivedIDs: Set<String> = []

                for document in snapshot.documents {
                    let data = document.data()

                    guard
                        let dealId = data["dealId"] as? String,
                        let relationType = data["relationType"] as? String
                    else {
                        continue
                    }

                    switch relationType {
                    case "saved":
                        savedIDs.insert(dealId)
                    case "archived":
                        archivedIDs.insert(dealId)
                    default:
                        break
                    }
                }

                self.savedDealIDs = savedIDs
                self.archivedDealIDs = archivedIDs
                self.isLoadingSavedDeals = false
                self.hasLoadedSavedDeals = true

                if let error {
                    print("Error fetching userDeals: \(error.localizedDescription)")
                }
            }
    }

    func seedMockDealsIfNeeded() async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user. Skipping mock deal seeding.")
            return
        }

        let seedRef = database.collection("appMetadata").document("mockDealSeed")

        do {
            let seedSnapshot = try await seedRef.getDocument()

            if seedSnapshot.exists {
                print("Mock deals already seeded.")
                return
            }

            let batch = database.batch()
            let now = Date()

            for deal in Deal.mockedDeals {
                let dealRef = database.collection("deals").document(deal.id)

                let dealData: [String: Any] = [
                    "title": deal.title,
                    "businessName": deal.businessName,
                    "description": deal.description,
                    "discountType": deal.discountType,
                    "expiration": Timestamp(date: deal.expiration),
                    "imageUrl": deal.imageUrl,
                    "location": deal.location,
                    "votes": deal.votes,
                    "createdByUid": currentUser.uid,
                    "createdByEmail": currentUser.email ?? "unknown@email.com",
                    "createdAt": Timestamp(date: deal.createdAt ?? now)
                ]

                batch.setData(dealData, forDocument: dealRef, merge: true)
            }

            batch.setData([
                "seeded": true,
                "seedName": "mockDeals",
                "seededByUid": currentUser.uid,
                "dealIDs": Deal.mockedDeals.map(\.id),
                "createdAt": Timestamp(date: now)
            ], forDocument: seedRef)

            try await batch.commit()
            print("Mock deals seeded successfully.")
        } catch {
            print("Error seeding mock deals: \(error.localizedDescription)")
        }
    }

    private func listenForDeals() {
        dealsListener?.remove()

        isLoadingDeals = true
        hasLoadedDeals = false

        dealsListener = database.collection("deals")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self else { return }

                guard let querySnapshot else {
                    if let error {
                        print("Error fetching deals: \(error.localizedDescription)")
                    }

                    self.isLoadingDeals = false
                    self.hasLoadedDeals = true
                    return
                }

                let fetchedDeals: [Deal] = querySnapshot.documents.compactMap { document in
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
                self.isLoadingDeals = false
                self.hasLoadedDeals = true

                if let error {
                    print("Error fetching deals: \(error.localizedDescription)")
                }
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

    func archiveExpiredDeals(for userID: String?) async {
        guard let userID else { return }

        let expiredDeals = Array(Set((savedDeals + submittedDeals(for: userID)).filter { $0.isExpired }))
            .sorted { $0.expiration < $1.expiration }

        guard !expiredDeals.isEmpty else { return }

        do {
            let batch = database.batch()

            for deal in expiredDeals where !archivedDealIDs.contains(deal.id) {
                let relationRef = database.collection("userDeals").document()
                batch.setData([
                    "userId": userID,
                    "dealId": deal.id,
                    "relationType": "archived",
                    "createdAt": Timestamp(date: Date())
                ], forDocument: relationRef)
            }

            try await batch.commit()
        } catch {
            print("Error archiving expired deals: \(error.localizedDescription)")
        }
    }
}

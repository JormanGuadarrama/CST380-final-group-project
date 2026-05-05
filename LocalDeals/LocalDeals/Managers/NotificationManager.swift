//
//  NotificationManager.swift
//  LocalDeals
//
//  Created by Kevin Crapo on 5/4/26.
//


import Foundation
import CoreLocation
import UserNotifications
import Observation
import FirebaseFirestore
@MainActor
@Observable
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let notifiedDealIDsKey = "notifiedNearbyDealIDs"

    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private override init() {
        super.init()
        notificationCenter.delegate = self

        Task {
            await refreshAuthorizationStatus()
        }
    }

    func requestPermission() async {
        do {
            _ = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            await refreshAuthorizationStatus()
        } catch {
            print("Error requesting notification permission: \(error.localizedDescription)")
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func notifyIfNeeded(
        for deal: Deal,
        currentLocation: CLLocation?,
        radiusMiles: Double,
        currentUserID: String?
    ) async {
        guard authorizationStatus == .authorized || authorizationStatus == .provisional else { return }
        guard let currentLocation else { return }
        guard !deal.isExpired else { return }
        // Uncomment this line after demo. It makes it so nearby deals don't notify if user submitted.
        //guard deal.createdByUid != currentUserID else { return }
        guard !hasAlreadyNotified(for: deal.id) else { return }

        let dealLocation = CLLocation(
            latitude: deal.location.latitude,
            longitude: deal.location.longitude
        )
        let distanceMiles = currentLocation.distance(from: dealLocation) / 1609.34

        guard distanceMiles <= radiusMiles else { return }

        let content = UNMutableNotificationContent()
        content.title = "New deal nearby"
        content.body = "\(deal.title) at \(deal.businessName) is \(String(format: "%.1f", distanceMiles)) miles away."
        content.sound = .default
        content.badge = 1
        content.userInfo = ["dealID": deal.id]

        let request = UNNotificationRequest(
            identifier: "nearby-deal-\(deal.id)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        do {
            try await notificationCenter.add(request)
            markNotified(for: deal.id)
        } catch {
            print("Error scheduling nearby deal notification: \(error.localizedDescription)")
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    private func hasAlreadyNotified(for dealID: String) -> Bool {
        let notifiedIDs = Set(UserDefaults.standard.stringArray(forKey: notifiedDealIDsKey) ?? [])
        return notifiedIDs.contains(dealID)
    }

    private func markNotified(for dealID: String) {
        var notifiedIDs = Set(UserDefaults.standard.stringArray(forKey: notifiedDealIDsKey) ?? [])
        notifiedIDs.insert(dealID)
        UserDefaults.standard.set(Array(notifiedIDs), forKey: notifiedDealIDsKey)
    }
}

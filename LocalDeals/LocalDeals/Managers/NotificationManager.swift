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
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            print("[Notification] Permission granted: \(granted)")

            await refreshAuthorizationStatus()
            print("[Notification] Authorization status after request: \(authorizationStatus.rawValue)")
        } catch {
            print("Error requesting notification permission: \(error.localizedDescription)")
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus

        print("[Notification] Refreshed authorization status: \(authorizationStatus.rawValue)")
    }

    func notifyIfNeeded(
        for deal: Deal,
        currentLocation: CLLocation?,
        radiusMiles: Double,
        currentUserID: String?
    ) async {
        print("[Notification] Checking deal: \(deal.title)")
        print("[Notification] Deal ID: \(deal.id)")
        print("[Notification] Authorization status: \(authorizationStatus.rawValue)")
        print("[Notification] Current location exists: \(currentLocation != nil)")
        print("[Notification] Deal expired: \(deal.isExpired)")
        print("[Notification] Deal creator: \(deal.createdByUid)")
        print("[Notification] Current user: \(currentUserID ?? "nil")")
        print("[Notification] Already notified: \(hasAlreadyNotified(for: deal.id))")
        print("[Notification] Radius miles: \(radiusMiles)")

        guard authorizationStatus == .authorized || authorizationStatus == .provisional else {
            print("[Notification] Blocked: notifications not authorized")
            return
        }

        guard let currentLocation else {
            print("[Notification] Blocked: no current location")
            return
        }

        guard !deal.isExpired else {
            print("[Notification] Blocked: deal is expired")
            return
        }

        // Uncomment this line after demo.
        // This prevents nearby deal alerts for deals submitted by the current user.
        /*
        guard deal.createdByUid != currentUserID else {
            print("[Notification] Blocked: user created this deal")
            return
        }
        */

        guard !hasAlreadyNotified(for: deal.id) else {
            print("[Notification] Blocked: already notified for this deal")
            return
        }

        let dealLocation = CLLocation(
            latitude: deal.location.latitude,
            longitude: deal.location.longitude
        )

        let distanceMiles = currentLocation.distance(from: dealLocation) / 1609.34

        print("[Notification] User location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        print("[Notification] Deal location: \(deal.location.latitude), \(deal.location.longitude)")
        print("[Notification] Distance miles: \(distanceMiles)")

        guard distanceMiles <= radiusMiles else {
            print("[Notification] Blocked: deal is outside radius")
            return
        }

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
            print("[Notification] Scheduled notification for \(deal.title)")
        } catch {
            print("[Notification] Error scheduling nearby deal notification: \(error.localizedDescription)")
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

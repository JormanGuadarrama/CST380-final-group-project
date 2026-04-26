//
//  AuthManager.swift
//  LocalDeals
//
//  Created by Kevin Crapo on 4/26/26.
//


import Foundation
import Observation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

@MainActor
@Observable
final class AuthManager {
    var user: User?
    var isSignedIn = false
    var authErrorMessage: String?

    let isMocked: Bool
    private var handle: AuthStateDidChangeListenerHandle?

    var userEmail: String? {
        isMocked ? "preview@localdeals.com" : user?.email
    }

    init(isMocked: Bool = false) {
        self.isMocked = isMocked

        if isMocked {
            self.isSignedIn = true
            return
        }

        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.user = user
            self.isSignedIn = (user != nil)
        }
    }

    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp(email: String, password: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            self.isSignedIn = true
            self.authErrorMessage = nil
        } catch {
            self.authErrorMessage = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            self.isSignedIn = true
            self.authErrorMessage = nil
        } catch {
            self.authErrorMessage = error.localizedDescription
        }
    }

    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.authErrorMessage = "Missing Firebase client ID. Re-download GoogleService-Info.plist after enabling Google Sign-In."
            return
        }

        guard let presentingViewController = topViewController() else {
            self.authErrorMessage = "Could not find a view controller for Google Sign-In."
            return
        }

        do {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDSignInResult, Error>) in
                GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let result else {
                        continuation.resume(throwing: NSError(
                            domain: "GoogleSignIn",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Google Sign-In returned no result."]
                        ))
                        return
                    }

                    continuation.resume(returning: result)
                }
            }

            guard let idToken = result.user.idToken?.tokenString else {
                self.authErrorMessage = "Google ID token was missing."
                return
            }

            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            let authResult = try await Auth.auth().signIn(with: credential)
            self.user = authResult.user
            self.isSignedIn = true
            self.authErrorMessage = nil
        } catch {
            self.authErrorMessage = error.localizedDescription
        }
    }

    func signOut() {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            self.user = nil
            self.isSignedIn = false
            self.authErrorMessage = nil
        } catch {
            self.authErrorMessage = error.localizedDescription
        }
    }

    private func topViewController(
        base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: \.isKeyWindow)?
            .rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }

        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }

        return base
    }
}
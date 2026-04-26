import Foundation
import Observation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import UIKit

typealias FirebaseUser = FirebaseAuth.User

@MainActor
@Observable
final class AuthManager {
    var firebaseUser: FirebaseUser?
    var isSignedIn = false
    var authErrorMessage: String?
    var user: User?

    let isMocked: Bool

    private let db = Firestore.firestore()
    private var handle: AuthStateDidChangeListenerHandle?

    var userEmail: String? {
        isMocked ? "preview@localdeals.com" : firebaseUser?.email
    }

    var userID: String? {
        isMocked ? "mock-user-id" : firebaseUser?.uid
    }

    init(isMocked: Bool = false) {
        self.isMocked = isMocked

        if isMocked {
            self.isSignedIn = true
            self.user = User(
                id: "mock-user-id",
                email: "preview@localdeals.com",
                username: "previewuser",
                displayName: "Preview User",
                photoURL: "",
                provider: "mock",
                createdAt: Date(),
                lastLoginAt: Date()
            )
            return
        }

        handle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self else { return }

            self.firebaseUser = firebaseUser
            self.isSignedIn = (firebaseUser != nil)

            if let firebaseUser {
                Task {
                    await self.syncUserDocument(for: firebaseUser, requestedUsername: nil)
                    await self.fetchCurrentUser()
                }
            } else {
                self.user = nil
            }
        }
    }



    func signUp(email: String, password: String, username: String) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmedEmail.isEmpty, !password.isEmpty, !trimmedUsername.isEmpty else {
            authErrorMessage = "Email, username, and password are required."
            return
        }

        guard password.count >= 9 else {
            authErrorMessage = "Password must be at least 9 characters."
            return
        }

        guard isValidUsername(trimmedUsername) else {
            authErrorMessage = "Username must be 3 to 20 characters and use only letters, numbers, underscores, or periods."
            return
        }

        do {
            let taken = try await usernameExists(trimmedUsername)
            if taken {
                authErrorMessage = "That username is already taken."
                return
            }

            let result = try await Auth.auth().createUser(withEmail: trimmedEmail, password: password)
            self.firebaseUser = result.user
            self.isSignedIn = true

            await syncUserDocument(for: result.user, requestedUsername: trimmedUsername)
            await fetchCurrentUser()

            self.authErrorMessage = nil
        } catch {
            self.authErrorMessage = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            authErrorMessage = "Email and password are required."
            return
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: trimmedEmail, password: password)
            self.firebaseUser = result.user
            self.isSignedIn = true

            await syncUserDocument(for: result.user, requestedUsername: nil)
            await fetchCurrentUser()

            self.authErrorMessage = nil
        } catch {
            self.authErrorMessage = error.localizedDescription
        }
    }

    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            authErrorMessage = "Missing Firebase client ID."
            return
        }

        guard let presentingViewController = topViewController() else {
            authErrorMessage = "Could not find a view controller for Google Sign-In."
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
                authErrorMessage = "Google ID token was missing."
                return
            }

            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            let authResult = try await Auth.auth().signIn(with: credential)
            self.firebaseUser = authResult.user
            self.isSignedIn = true

            await syncUserDocument(for: authResult.user, requestedUsername: nil)
            await fetchCurrentUser()

            self.authErrorMessage = nil
        } catch {
            self.authErrorMessage = error.localizedDescription
        }
    }

    func signOut() {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            self.firebaseUser = nil
            self.user = nil
            self.isSignedIn = false
            self.authErrorMessage = nil
        } catch {
            self.authErrorMessage = error.localizedDescription
        }
    }

    private func syncUserDocument(for firebaseUser: FirebaseUser, requestedUsername: String?) async {
        do {
            let ref = db.collection("users").document(firebaseUser.uid)
            let snapshot = try await ref.getDocument()

            let existingData = snapshot.data()
            let existingUsername = existingData?["username"] as? String
            let provider = firebaseUser.providerData.first?.providerID ?? "password"

            let finalUsername: String
            if let existingUsername, !existingUsername.isEmpty {
                finalUsername = existingUsername
            } else if let requestedUsername, !requestedUsername.isEmpty {
                finalUsername = requestedUsername
            } else {
                let seed = defaultUsernameSeed(for: firebaseUser)
                finalUsername = try await makeUniqueUsername(from: seed)
            }

            var data: [String: Any] = [
                "uid": firebaseUser.uid,
                "email": firebaseUser.email ?? "",
                "username": finalUsername,
                "displayName": firebaseUser.displayName ?? finalUsername,
                "photoURL": firebaseUser.photoURL?.absoluteString ?? "",
                "provider": provider,
                "lastLoginAt": Timestamp(date: Date())
            ]

            if !snapshot.exists {
                data["createdAt"] = Timestamp(date: Date())
            }

            try await ref.setData(data, merge: true)
        } catch {
            self.authErrorMessage = error.localizedDescription
        }
    }

    private func fetchCurrentUser() async {
        guard let uid = firebaseUser?.uid else { return }

        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()

            guard let data = snapshot.data(),
                  let email = data["email"] as? String,
                  let username = data["username"] as? String,
                  let displayName = data["displayName"] as? String,
                  let photoURL = data["photoURL"] as? String,
                  let provider = data["provider"] as? String else {
                return
            }

            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
            let lastLoginAt = (data["lastLoginAt"] as? Timestamp)?.dateValue()

            self.user = User(
                id: uid,
                email: email,
                username: username,
                displayName: displayName,
                photoURL: photoURL,
                provider: provider,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt
            )
        } catch {
            self.authErrorMessage = error.localizedDescription
        }
    }

    private func usernameExists(_ username: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments()

        return !snapshot.documents.isEmpty
    }

    private func makeUniqueUsername(from seed: String) async throws -> String {
        var candidate = normalizedUsername(seed)

        if candidate.count < 3 {
            candidate += "user"
        }

        candidate = String(candidate.prefix(20))

        if !(try await usernameExists(candidate)) {
            return candidate
        }

        for index in 1...9999 {
            let suffix = "\(index)"
            let prefixLength = max(3, 20 - suffix.count)
            let prefix = String(candidate.prefix(prefixLength))
            let candidateWithSuffix = prefix + suffix

            if !(try await usernameExists(candidateWithSuffix)) {
                return candidateWithSuffix
            }
        }

        return "\(String(candidate.prefix(12)))\(UUID().uuidString.prefix(6)).lowercased()"
    }

    private func defaultUsernameSeed(for firebaseUser: FirebaseUser) -> String {
        if let email = firebaseUser.email,
           let localPart = email.split(separator: "@").first {
            return String(localPart)
        }

        if let displayName = firebaseUser.displayName, !displayName.isEmpty {
            return displayName
        }

        return "user\(firebaseUser.uid.prefix(6))"
    }

    private func normalizedUsername(_ value: String) -> String {
        let lowercased = value.lowercased()
        return lowercased.filter { character in
            character.isLetter || character.isNumber || character == "_" || character == "."
        }
    }

    private func isValidUsername(_ username: String) -> Bool {
        let normalized = normalizedUsername(username)
        return normalized == username && (3...20).contains(username.count)
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

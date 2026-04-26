import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @Environment(AuthManager.self) var authManager

    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isRegisterMode = false

    var body: some View {
        VStack(spacing: 20) {
            Text(isRegisterMode ? "Create Account" : "Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                if isRegisterMode {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }

                SecureField("Password", text: $password)
                    .textContentType(isRegisterMode ? .newPassword : .password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                if isRegisterMode {
                    Text("Username must be 3 to 20 characters. Password must be at least 9 characters.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal)

            Button {
                Task {
                    if isRegisterMode {
                        await authManager.signUp(
                            email: email,
                            password: password,
                            username: username
                        )
                    } else {
                        await authManager.signIn(
                            email: email,
                            password: password
                        )
                    }
                }
            } label: {
                Text(isRegisterMode ? "Register" : "Sign In")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(
                email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                password.isEmpty ||
                (isRegisterMode && username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )

            GoogleSignInButton {
                Task {
                    await authManager.signInWithGoogle()
                }
            }
            .frame(height: 50)
            .padding(.horizontal)

            Button {
                isRegisterMode.toggle()
                authManager.authErrorMessage = nil
            } label: {
                Text(
                    isRegisterMode
                    ? "Already have an account? Sign In"
                    : "New here? Create an account"
                )
                .font(.footnote)
            }

            if let error = authManager.authErrorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle(isRegisterMode ? "Register" : "Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environment(AuthManager(isMocked: true))
    }
}

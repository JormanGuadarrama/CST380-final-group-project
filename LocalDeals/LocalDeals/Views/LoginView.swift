import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @Environment(AuthManager.self) var authManager

    @State private var email = ""
    @State private var password = ""
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
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .textContentType(isRegisterMode ? .newPassword : .password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Button {
                Task {
                    if isRegisterMode {
                        await authManager.signUp(email: email, password: password)
                    } else {
                        await authManager.signIn(email: email, password: password)
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
            .disabled(email.isEmpty || password.isEmpty)

            GoogleSignInButton {
                Task {
                    await authManager.signInWithGoogle()
                }
            }
            .frame(height: 50)
            .padding(.horizontal)

            Button {
                isRegisterMode.toggle()
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

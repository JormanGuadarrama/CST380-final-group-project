//
//  LoginView.swift
//  LocalDeals
//
//  Basic email/password fields and submit button (placeholder).
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegisterMode: Bool = false

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
                    .autocapitalization(.none)
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

            Button(action: {
                // TODO: hook into Firebase Auth (#16, #19)
            }) {
                Text(isRegisterMode ? "Register" : "Sign In")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(email.isEmpty || password.isEmpty)

            Button(action: { isRegisterMode.toggle() }) {
                Text(isRegisterMode
                     ? "Already have an account? Sign In"
                     : "New here? Create an account")
                    .font(.footnote)
            }

            Spacer()
        }
        .navigationTitle(isRegisterMode ? "Register" : "Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { LoginView() }
}

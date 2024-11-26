//
//  SignIn.swift
//  FreshUpEdgeUp
//
//  Created by Landon Williams on 11/25/24.
//


import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var showForgotPasswordAlert = false
    @State private var forgotPasswordEmail: String = ""
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 120)
                .padding(.vertical, 32)

            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .padding(.top, 20)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .padding(.top, 20)

            Button(action: signIn) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top)
            }

            Spacer()

            // Forgot Password Button
            Button(action: {
                showForgotPasswordAlert = true
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
                    .underline()
            }
            .padding(.bottom, 10)

            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.white)

                NavigationLink(destination: SignUpView().environmentObject(authViewModel)) {
                    Text("Create Account")
                        .foregroundColor(.white)
                        .underline()
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color.black.ignoresSafeArea())
        .alert("Forgot Password", isPresented: $showForgotPasswordAlert, actions: {
            TextField("Enter your email", text: $forgotPasswordEmail)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            Button("Reset Password") {
                resetPassword(email: forgotPasswordEmail)
            }
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("Enter your email address to reset your password.")
        })
    }

    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
        }
    }

    private func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = "Failed to send reset email: \(error.localizedDescription)"
            } else {
                errorMessage = "Password reset email sent. Check your inbox."
            }
        }
    }
}

// Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthViewModel()) // Mock environment object for preview
    }
}

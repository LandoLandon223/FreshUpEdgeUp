//
//  SignUp.swift
//  FreshUpEdgeUp
//
//  Created by Landon Williams on 11/25/24.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SignUpView: View {
    @State private var fullname: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var userType: String = "Client"  // Default to Client
    @State private var errorMessage: String?

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 120)
                .padding(.vertical, 32)

            TextField("Full Name", text: $fullname)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 24)

            TextField("Username", text: $username)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 24)

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 24)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 24)

            // User type selection (Picker)
            Picker("Select User Type", selection: $userType) {
                Text("Client").tag("Client")
                Text("Barber/Stylist").tag("Barber/Stylist")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Button(action: signUp) {
                Text("Create Account")
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
        }
        .background(Color.black.ignoresSafeArea())
    }

    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            guard let userID = result?.user.uid else { return }

            let db = Firestore.firestore()
            db.collection("users").document(userID).setData([
                "fullname": fullname,
                "username": username,
                "email": email,
                "userType": userType // Save the selected userType (Barber or Client)
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                // Update AuthViewModel
                authViewModel.userSession = result?.user
                authViewModel.userData = UserData(fullname: fullname, username: username, email: email, userType: userType)
                authViewModel.userDataLoaded = true

                presentationMode.wrappedValue.dismiss() // Dismiss SignUpView
            }
        }
    }
}

// Preview
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthViewModel()) // Mock environment object for preview
    }
}

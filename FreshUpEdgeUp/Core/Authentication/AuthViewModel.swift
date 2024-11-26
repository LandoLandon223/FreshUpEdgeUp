//
//  AuthViewModel.swift
//  FreshUpEdgeUp
//
//  Created by Landon Williams on 11/25/24.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

struct UserData: Identifiable {
    var id: String { email } // Use email as a unique identifier
    let fullname: String
    let username: String
    let email: String
    var userType: String // Barber/Stylist or Client
}

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var userData: UserData?
    @Published var userDataLoaded = false

    init() {
        listenToAuthChanges()
    }

    private func listenToAuthChanges() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.userSession = user
            self.isAuthenticated = user != nil
            if let user = user {
                self.fetchUserData(userID: user.uid)
            }
        }
    }

    private func fetchUserData(userID: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else { return }
            self.userData = UserData(
                fullname: data["fullname"] as? String ?? "",
                username: data["username"] as? String ?? "",
                email: data["email"] as? String ?? "",
                userType: data["userType"] as? String ?? "Client" // Default to "Client"
            )
            self.userDataLoaded = true
        }
    }

    func deleteAccount(completion: @escaping (Error?) -> Void) {
        guard let user = userSession else {
            return completion(
                NSError(
                    domain: "Auth",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No user session available"]
                )
            )
        }

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).delete { error in
            if let error = error {
                completion(error)
                return
            }

            user.delete { error in
                completion(error)
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        userSession = nil
        userData = nil
        isAuthenticated = false
        userDataLoaded = false
    }
}

//
//  EditProfileVeiw.swift
//  FreshUpEdgeUp
//
//  Created by Landon Williams on 11/26/24.
//

import SwiftUI
import FirebaseFirestore

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var userData: UserData // Use Binding for two-way updates
    @Environment(\.presentationMode) var presentationMode

    @State private var editedUsername: String = ""
    @State private var editedEmail: String = ""
    @State private var editedUserType: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Username")) {
                    TextField("Username", text: $editedUsername)
                }

                Section(header: Text("Email")) {
                    TextField("Email", text: $editedEmail)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }

                Section(header: Text("User Type")) {
                    Picker("User Type", selection: $editedUserType) {
                        Text("Client").tag("Client")
                        Text("Barber/Stylist").tag("Barber/Stylist")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveChanges()
            })
            .onAppear {
                // Populate editable fields with initial userData values
                editedUsername = userData.username
                editedEmail = userData.email
                editedUserType = userData.userType
            }
        }
    }

    private func saveChanges() {
        guard let userSession = authViewModel.userSession else { return }

        let db = Firestore.firestore()
        db.collection("users").document(userSession.uid).updateData([
            "username": editedUsername,
            "email": editedEmail,
            "userType": editedUserType
        ]) { error in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
            } else {
                // Update the entire userData object using the Binding
                userData = UserData(
                    fullname: userData.fullname, // Retain unchanged properties
                    username: editedUsername,
                    email: editedEmail,
                    userType: editedUserType
                )

                presentationMode.wrappedValue.dismiss() // Close the view
            }
        }
    }
}

//
//  SettingsView.swift
//  FreshUpEdgeUp
//
//  Created by Landon Williams on 11/26/24.
//

import SwiftUI
import FirebaseFirestore

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteConfirmation = false
    @State private var deleteErrorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea() // Background color

                VStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    Spacer().frame(height: 20)

                    Form {
                        Section(header: Text("Account")
                            .font(.headline)
                            .foregroundColor(.white)
                        ) {
                            Button(action: {
                                authViewModel.signOut()
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Logout")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                                    .padding(.vertical, 5)
                            }
                            .listRowBackground(Color.black)

                            Button(role: .destructive, action: {
                                showDeleteConfirmation = true
                            }) {
                                Text("Delete Account")
                                    .foregroundColor(.red)
                                    .font(.headline)
                                    .padding(.vertical, 5)
                            }
                            .listRowBackground(Color.black)
                        }
                    }
                    .scrollContentBackground(.hidden) // Ensure form background is transparent
                    .background(Color.black) // Background for the form
                    .cornerRadius(10)
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteAccount()
                        },
                        secondaryButton: .cancel()
                    )
                }
                .alert("Error", isPresented: .constant(deleteErrorMessage != nil), actions: {
                    Button("OK", role: .cancel) {
                        deleteErrorMessage = nil
                    }
                }, message: {
                    Text(deleteErrorMessage ?? "")
                })
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }

    private func deleteAccount() {
        authViewModel.deleteAccount { error in
            if let error = error {
                deleteErrorMessage = error.localizedDescription
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthViewModel()) // Mock environment object
    }
}

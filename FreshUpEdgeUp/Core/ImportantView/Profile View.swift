//
//  Profile View.swift
//  FreshUpEdgeUp
//
//  Created by Landon Williams on 11/25/24.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditing = false
    @State private var isBooking = false
    @State private var isPosting = false
    @State private var isViewingAppointments = false
    @State private var editableUserData: UserData

    init(userData: UserData) {
        _editableUserData = State(initialValue: userData)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.2)
                            .padding(.top, 20)

                        Image("ProfilePicturePlaceholder")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                            .frame(width: geometry.size.width * 0.3)
                    }

                    // User Info
                    Text(editableUserData.fullname)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text(editableUserData.userType)
                        .font(.headline)
                        .foregroundColor(.blue)

                    VStack(spacing: 12) {
                        ProfileInfoRow(label: "Username", value: editableUserData.username)
                        ProfileInfoRow(label: "Email", value: editableUserData.email)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)

                    // Buttons
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            Button(action: {
                                isEditing = true
                            }) {
                                Text("Edit Profile")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }

                            Button(action: {
                                isBooking = true
                            }) {
                                Text("Book")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            }
                        }

                        if editableUserData.userType == "Barber/Stylist" {
                            Button(action: {
                                isPosting = true
                            }) {
                                Text("Post")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            }
                        }

                        Button(action: {
                            isViewingAppointments = true
                        }) {
                            Text("Appointments")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .sheet(isPresented: $isBooking) {
                BookingView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $isEditing) {
                EditProfileView(userData: $editableUserData)
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $isViewingAppointments) {
                AppointmentView()
                    .environmentObject(authViewModel)
            }
        }
        .navigationBarItems(trailing: NavigationLink(destination: SettingsView().environmentObject(authViewModel)) {
            Image(systemName: "gearshape.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.blue)
        })
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.blue)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}

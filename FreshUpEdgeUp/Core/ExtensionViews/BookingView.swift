//
//  BookingView.swift
//  FreshUpEdgeUp
//
//  Created by Landon Williams on 11/26/24.
//

import SwiftUI
import FirebaseFirestore

struct BookingView: View {
    @State private var searchQuery = ""
    @State private var searchResults: [UserData] = []
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode // For dismissing if presented as a sheet

    init() {
        // Customize the navigation bar title appearance
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background Color
                Color.black.ignoresSafeArea()

                VStack(spacing: 16) {
                    // Back Button
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss() // Dismiss the view
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.blue)
                                Text("Back")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Search Bar
                    TextField("Search for barbers/stylists...", text: $searchQuery, onCommit: {
                        searchUsers(query: searchQuery)
                    })
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                    // Results List
                    if searchResults.isEmpty && !searchQuery.isEmpty {
                        Text("No results found")
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {
                        List(searchResults) { user in
                            NavigationLink(destination: UserProfileView(user: user)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.fullname)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("@\(user.username)")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 8)
                            }
                            .listRowBackground(Color.black) // List row background
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden) // Ensures list background is transparent
                    }

                    Spacer()
                }
            }
            .navigationTitle("Search Barbers/Stylists")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func searchUsers(query: String) {
        guard !query.isEmpty else {
            self.searchResults = [] // Clear results if the query is empty
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .whereField("userType", isEqualTo: "Barber/Stylist") // Filter for barbers/stylists
            .whereField("lowercaseUsername", isGreaterThanOrEqualTo: query.lowercased())
            .whereField("lowercaseUsername", isLessThanOrEqualTo: query.lowercased() + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error searching users: \(error.localizedDescription)")
                    return
                }

                if let documents = snapshot?.documents {
                    self.searchResults = documents.compactMap { doc -> UserData? in
                        let data = doc.data()
                        return UserData(
                            fullname: data["fullname"] as? String ?? "",
                            username: data["username"] as? String ?? "",
                            email: data["email"] as? String ?? "",
                            userType: data["userType"] as? String ?? "Client"
                        )
                    }
                }
            }
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView()
            .environmentObject(AuthViewModel())
    }
}

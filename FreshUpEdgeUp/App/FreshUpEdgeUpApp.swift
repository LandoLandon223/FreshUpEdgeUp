//
//  FreshUpEdgeUpApp.swift
//  FreshUpEdgeUp
//
//  Created by Landon Williams on 11/25/24.
//

import SwiftUI
import FirebaseCore

@main
struct FreshUpEdgeUpApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel() // Instantiate AuthViewModel

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black.ignoresSafeArea() // Background
                NavigationView {
                    if authViewModel.isAuthenticated {
                        if authViewModel.userDataLoaded {
                            ProfileView(userData: authViewModel.userData!)
                                .environmentObject(authViewModel) // Provide environment object
                        } else {
                            SignUpView()
                                .environmentObject(authViewModel) // Provide environment object
                        }
                    } else {
                        SignInView()
                            .environmentObject(authViewModel) // Provide environment object
                    }
                }
            }
        }
    }
}

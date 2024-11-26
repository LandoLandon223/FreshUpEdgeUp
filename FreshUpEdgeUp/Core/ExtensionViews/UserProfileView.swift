//
//  UserProfileView.swift
//  FreshUpEdgeUp
//
//  Created by Landon Williams on 11/26/24.
//
//Couldn't figure out how to completley search up other users in data base so didnt worry too much about how to fix in 

import SwiftUI

struct UserProfileView: View {
    let user: UserData

    var body: some View {
        VStack(spacing: 20) {
            Image("ProfilePicturePlaceholder")
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 4))
                .frame(width: 150, height: 150)

            Text(user.fullname)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("@\(user.username)")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}

// Preview
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUser = UserData(
            fullname: "John Doe",
            username: "johndoe",
            email: "johndoe@example.com",
            userType: "Barber/Stylist"
        )

        UserProfileView(user: sampleUser)
    }
}

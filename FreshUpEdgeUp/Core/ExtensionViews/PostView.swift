//
//  PostView.swift
//  FreshUpEdgeUp
//
//  Created by Landon Williams on 11/26/24.
//
//wasnt able to figure out the complete functionality of this feature 

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct PostView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedImage: UIImage?
    @State private var imagePickerPresented = false
    @State private var uploadProgress: Double = 0.0
    @State private var isUploading = false
    @State private var uploadError: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Upload Picture")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Display selected image or button to select image
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300, maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 3)
                            )
                    } else {
                        Button(action: {
                            imagePickerPresented = true
                        }) {
                            Text("Select an Image")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 24)
                    }

                    // Upload button or progress view
                    if isUploading {
                        ProgressView(value: uploadProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.horizontal, 24)
                            .foregroundColor(.blue)
                    } else if selectedImage != nil {
                        Button(action: uploadImage) {
                            Text("Upload")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 24)
                    }

                    // Display upload error message if any
                    if let uploadError = uploadError {
                        Text(uploadError)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $imagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }

    private func uploadImage() {
        guard let selectedImage = selectedImage,
              let user = authViewModel.userSession else {
            uploadError = "No image selected or user not authenticated."
            return
        }

        isUploading = true
        uploadError = nil
        let storageRef = Storage.storage().reference().child("profile_images/\(user.uid)_\(UUID().uuidString).jpg")

        // Compress the image
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            uploadError = "Failed to compress image."
            isUploading = false
            return
        }

        // Upload the image
        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                uploadError = "Upload failed: \(error.localizedDescription)"
                isUploading = false
                return
            }

            // Get the image download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    uploadError = "Failed to get image URL: \(error.localizedDescription)"
                    isUploading = false
                    return
                }

                guard let url = url else {
                    uploadError = "Image URL is missing."
                    isUploading = false
                    return
                }

                // Save the image URL to Firestore
                saveImageURLToProfile(imageURL: url)
            }
        }

        // Track upload progress
        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
                uploadProgress = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            }
        }
    }

    private func saveImageURLToProfile(imageURL: URL) {
        let db = Firestore.firestore()
        guard let user = authViewModel.userSession else { return }

        db.collection("users").document(user.uid).updateData([
            "profileImages": FieldValue.arrayUnion([imageURL.absoluteString])
        ]) { error in
            if let error = error {
                uploadError = "Failed to save image URL: \(error.localizedDescription)"
            } else {
                uploadError = nil
            }
            isUploading = false
        }
    }
}

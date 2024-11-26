//
//  AppointmentView.swift
//  FreshUpEdgeUp
//
//  Created by Landon Williams on 11/26/24.
//

import SwiftUI
import FirebaseFirestore

struct AppointmentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var appointments: [Appointment] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        List(appointments) { appointment in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(appointment.barberName)
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text(appointment.date)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)

                                Text(appointment.status)
                                    .font(.subheadline)
                                    .foregroundColor(appointment.status == "Completed" ? .green : .yellow)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                    }
                }
                .padding()
                .navigationTitle("Appointments")
                .onAppear(perform: fetchAppointments)
            }
        }
    }

    private func fetchAppointments() {
        let db = Firestore.firestore()

        guard let user = authViewModel.userSession else {
            errorMessage = "User not authenticated."
            return
        }

        db.collection("appointments")
            .whereField("clientID", isEqualTo: user.uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to load appointments: \(error.localizedDescription)"
                } else {
                    self.appointments = snapshot?.documents.compactMap { doc -> Appointment? in
                        let data = doc.data()
                        guard
                            let barberName = data["barberName"] as? String,
                            let date = data["date"] as? String,
                            let status = data["status"] as? String
                        else { return nil }

                        return Appointment(
                            id: doc.documentID,
                            barberName: barberName,
                            date: date,
                            status: status
                        )
                    } ?? []
                }
            }
    }
}

struct Appointment: Identifiable {
    let id: String
    let barberName: String
    let date: String
    let status: String
}

struct AppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentView()
            .environmentObject(AuthViewModel()) // Mock environment object
    }
}

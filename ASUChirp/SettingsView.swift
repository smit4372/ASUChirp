//
//  SettingsView.swift
//  ASUChirp
//
//  Created by Smit Desai on 3/29/25.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showLogoutConfirmation = false
    @State private var isLoading = false
    
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle(isOn: $isDarkMode) {
                    Label("Dark Mode", systemImage: "moon.fill")
                }
            }
            
            Section(header: Text("About")) {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Label("Made for", systemImage: "building.columns")
                    Spacer()
                    Text("ASU Students")
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("Account")) {
                Button(action: {
                    showLogoutConfirmation = true
                }) {
                    HStack {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                .alert(isPresented: $showLogoutConfirmation) {
                    Alert(
                        title: Text("Logout"),
                        message: Text("Are you sure you want to logout?"),
                        primaryButton: .destructive(Text("Logout")) {
                            isLoading = true
                            sessionViewModel.signOut()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            Group {
                if isLoading {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    
                    ProgressView()
                }
            }
        )
    }
}

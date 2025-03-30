//
//  SettingsView.swift
//  ASUChirp
//
//  Created by Smit Desai on 3/29/25.
//
//
//import SwiftUI
//
//struct SettingsView: View {
//    @EnvironmentObject var sessionStore: SessionStore
//    
//    var body: some View {
//        VStack {
//            Text("Settings")
//                .font(.largeTitle)
//                .padding()
//            Spacer()
//            Button("Logout") {
//                sessionStore.signOut()
//            }
//            .padding()
//            Spacer()
//        }
//    }
//}

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                    }
                }
                
                Section(header: Text("Profile")) {
                    Button("Edit Profile") {
                        showingEditProfile = true
                    }
                    .sheet(isPresented: $showingEditProfile) {
                        EditProfileView()
                    }
                }
                
                Section {
                    Button("Logout") {
                        sessionStore.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

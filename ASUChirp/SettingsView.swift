
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

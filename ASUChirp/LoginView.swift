//
//  LoginView.swift
//  ASUChirp
//
//  Created by Smit Desai on 3/29/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("ASU Chirp")
                    .font(.largeTitle)
                    .padding(.bottom, 40)
                
                TextField("ASU Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                if isLoading {
                    ProgressView()
                }
                
                HStack(spacing: 30) {
                    Button("Login") {
                        login()
                    }
                    
                    Button("Sign Up") {
                        signUp()
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }
    
    func login() {
        guard validateEmail(email) else {
            errorMessage = "Please use your ASU email."
            return
        }
        isLoading = true
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signUp() {
        guard validateEmail(email) else {
            errorMessage = "Please use your ASU email."
            return
        }
        isLoading = true
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func validateEmail(_ email: String) -> Bool {
        return email.lowercased().hasSuffix("@asu.edu")
    }
}

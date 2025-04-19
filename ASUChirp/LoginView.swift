//
//  LoginView.swift
//  ASUChirp
//
//  Created by Smit Desai on 3/29/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject private var viewModel = SessionViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Logo and Title
                    VStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("ASU Chirp")
                            .font(.largeTitle)
                            .bold()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Form Fields
                    VStack(spacing: 15) {
                        TextField("ASU Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        if isSignUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                            
                            TextField("Username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Login/Signup Button
                    Button(action: {
                        if isSignUp {
                            viewModel.signUp(
                                email: email,
                                password: password,
                                passwordConfirm: confirmPassword,
                                username: username
                            ) { _ in }
                        } else {
                            viewModel.login(email: email, password: password) { _ in }
                        }
                    }) {
                        Text(isSignUp ? "Sign Up" : "Log In")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(viewModel.isLoading || !isValidInput)
                    
                    // Toggle between Login and Signup
                    Button(action: {
                        isSignUp.toggle()
                        // Clear fields when switching modes
                        if isSignUp {
                            // Keep email if already entered
                            password = ""
                            confirmPassword = ""
                            username = email.components(separatedBy: "@").first ?? ""
                        } else {
                            confirmPassword = ""
                            // Keep email and password when going back to login
                        }
                    }) {
                        Text(isSignUp ? "Already have an account? Log In" : "New to ASU Chirp? Sign Up")
                            .foregroundColor(.blue)
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top)
                    }
                    
                    Spacer()
                    
                    // Information footer
                    VStack(spacing: 5) {
                        Text("ASU Chirp is exclusively for ASU students")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("Please use your @asu.edu email to sign up")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    private var isValidInput: Bool {
        let isEmailValid = !email.isEmpty && email.lowercased().hasSuffix("@asu.edu")
        let isPasswordValid = !password.isEmpty && password.count >= 6
        
        if isSignUp {
            let isConfirmPasswordValid = password == confirmPassword
            let isUsernameValid = !username.isEmpty
            return isEmailValid && isPasswordValid && isConfirmPasswordValid && isUsernameValid
        } else {
            return isEmailValid && isPasswordValid
        }
    }
}

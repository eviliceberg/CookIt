//
//  SignUpView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-08.
//

import SwiftUI

@MainActor
final class SignUpViewModel: ObservableObject {
    
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signUp() async throws -> Bool {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            throw CookItErrors.noData
        }
        if try await !UserManager.shared.emailExists(userEmail: email) {
            let authUser = try await AuthenticationManager.shared.createUser(email: email, password: password, username: username)
            let user = DBUser(auth: authUser)
            try await UserManager.shared.createNewUser(user: user)
            return false
        } else {
            return true
        }
    }
    
}

struct SignUpView: View {
    
    @StateObject private var vm = SignUpViewModel()
    
    @State private var confirmPassword: String = ""
    @State private var showAlert: Bool = false
    @State private var emailExist: Bool = false
    
    @Binding var showWelcomeScreen: Bool
    
    enum FieldType: Equatable {
        case secure
        case text
    }
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter your username:")
                        .font(.title2)
                        .fontWeight(.bold)

                    reusableField(fieldType: .text, placeholder: "Enter your username...", text: $vm.username)
                    
                    Text("Enter your email:")
                        .font(.title2)
                        .fontWeight(.bold)
                    reusableField(fieldType: .text, placeholder: "Enter your email...", text: $vm.email)
                    
                    Text("Enter your password:")
                        .font(.title2)
                        .fontWeight(.bold)
                    reusableField(fieldType: .secure, placeholder: "Enter your password...", text: $vm.password)
                    
                    Text("Confirm password:")
                        .font(.title2)
                        .fontWeight(.bold)
                    reusableField(fieldType: .secure, placeholder: "Enter your password...", text: $confirmPassword)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 8)
                
                
                Text("Sign Up")
                    .foregroundStyle(.specialBlack)
                    .font(.title)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(.specialYellow)
                    .clipShape(.rect(cornerRadius: 16))
                    .padding(.bottom, 16)
                    .asButton(.tap) {
                        if confirmPassword == vm.password && !confirmPassword.isEmpty {
                            Task {
                                do {
                                    if try await vm.signUp() {
                                        emailExist = true
                                    } else {
                                        showWelcomeScreen = false
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                        } else {
                            showAlert = true
                        }
                    }
                
            }
            .foregroundStyle(.specialWhite)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .alert("Your confirmation password does not match your password", isPresented: $showAlert) {
                Button("Try again", role: .cancel) {
                    showAlert = false
                }
            }
            .alert("Account with this email already exists. Try another one.", isPresented: $emailExist) {
                Button("Ok", role: .cancel) {
                    emailExist = false
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Sign Up")
    }
    
    private func reusableField(fieldType: FieldType, placeholder: String, text: Binding<String>) -> some View {
        AnyView(
            VStack {
                if fieldType == .secure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .padding()
            .background(.specialBlack)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 3)
                    .foregroundStyle(.specialDarkGrey)
            }
        )
    }
    
}

#Preview {
    NavigationStack {
        SignUpView(showWelcomeScreen: .constant(true))
    }
}

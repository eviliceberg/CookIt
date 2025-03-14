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
    
    @Binding var showMainScreen: Bool
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            VStack {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70)
                    .padding(.bottom, 48)
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.specialDarkGrey)
                            .fontWeight(.bold)
                            .imageScale(.medium)
                        
                        SuperTextField(textFieldType: .regular, placeholder: Text("Enter your username")
                            .font(.custom(Constants.appFontMedium, size: 16))
                            .foregroundStyle(.specialLightGray), text: $vm.username)
                    }
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.specialDarkGrey)
                    }
                    
                    HStack {
                        Image(systemName: "at")
                            .foregroundStyle(.specialDarkGrey)
                            .fontWeight(.bold)
                            .imageScale(.medium)
                        
                        SuperTextField(textFieldType: .email, placeholder: Text("Enter your email")
                            .font(.custom(Constants.appFontMedium, size: 16))
                            .foregroundStyle(.specialLightGray), text: $vm.email)
                    }
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.specialDarkGrey)
                    }
                }
                .padding(.top, 8)
                
                Text("Password")
                    .foregroundStyle(.specialWhite)
                    .font(.custom(Constants.appFontMedium, size: 18))
                    .padding(.top, 16)
                    .offset(y: 12)
                    
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.specialDarkGrey)
                            .fontWeight(.bold)
                            .imageScale(.medium)
                        
                        SuperTextField(textFieldType: .secure, placeholder: Text("Must be 6 characters")
                            .font(.custom(Constants.appFontMedium, size: 16))
                            .foregroundStyle(.specialLightGray), text: $vm.password)
                    }
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.specialDarkGrey)
                    }
                    
                    HStack {
                        Image(systemName: "exclamationmark.lock.fill")
                            .foregroundStyle(.specialDarkGrey)
                            .fontWeight(.bold)
                            .imageScale(.medium)
                        
                        SuperTextField(textFieldType: .secure, placeholder: Text("Repeat your password")
                            .font(.custom(Constants.appFontMedium, size: 16))
                            .foregroundStyle(.specialLightGray), text: $confirmPassword)
                    }
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.specialDarkGrey)
                    }
                    
                }
                
                Text("Login")
                    .foregroundStyle(.specialBlack)
                    .font(.custom(Constants.appFontBold, size: 24))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(.specialGreen)
                    .clipShape(.rect(cornerRadius: 26))
                    .padding(.top, 48)
                    .asButton(.tap) {
                        if confirmPassword == vm.password && !confirmPassword.isEmpty {
                            Task {
                                do {
                                    if try await vm.signUp() {
                                        emailExist = true
                                    } else {
                                        showMainScreen = false
                                        showWelcomeScreen = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                showMainScreen = true
                                            }
                                        }
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
    }
}

#Preview {
    NavigationStack {
        SignUpView(showWelcomeScreen: .constant(true), showMainScreen: .constant(true))
    }
}

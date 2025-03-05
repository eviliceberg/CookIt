//
//  ContentView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-06.
//

import SwiftUI
import SwiftfulUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class WelcomeViewModel: ObservableObject {
    
    @Published var emailText: String = ""
    @Published var passwordText: String = ""
    
    func signIn() async throws {
        guard !emailText.isEmpty, !passwordText.isEmpty else {
            throw CookItErrors.noEmailOrPassword
        }
        try await AuthenticationManager.shared.signInUser(email: emailText, password: passwordText)
    }
    func continueWithGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authUser = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authUser)
        if try await !UserManager.shared.userExists(userId: user.userId) {
            try await UserManager.shared.createNewUser(user: user)
        }
    }
    
    func continueWithApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let authUser = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
        let user = DBUser(auth: authUser)
        if try await !UserManager.shared.userExists(userId: user.userId) {
            try await UserManager.shared.createNewUser(user: user)
        }
    }
    
    func continueAnounimously() async throws {
        let authUser = try await AuthenticationManager.shared.signInAnonymous()
        let user = DBUser(auth: authUser)
        if try await !UserManager.shared.userExists(userId: user.userId) {
            try await UserManager.shared.createNewUser(user: user)
        }
    }
}

struct WelcomeView: View {
    
    //    @State private var animateLogo: Bool = false
    @State private var animateSymbol: Bool = false
    
    @Binding var showWelcomeScreen: Bool
    
    @Binding var showMainScreen: Bool
    
    @StateObject private var vm: WelcomeViewModel = WelcomeViewModel()
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .padding(.bottom)
                
                SuperTextField(
                    textFieldType: .regular,
                    placeholder: Text("Enter your email...")
                        .foregroundStyle(.specialLightGray)
                        .font(.custom(Constants.appFontMedium, size: 16)),
                    text: $vm.emailText)
                .padding()
                .background(.specialBlack)
                .overlay {
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(.specialDarkGrey)
                }
                
                SuperTextField(
                    textFieldType: .secure,
                    placeholder: Text("Enter your password...")
                        .foregroundStyle(.specialLightGray)
                        .font(.custom(Constants.appFontMedium, size: 16)),
                    text: $vm.passwordText)
                .padding()
                .background(.specialBlack)
                .overlay {
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(.specialDarkGrey)
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 1)
                        .frame(height: 0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("or")
                        .font(.custom(Constants.appFontMedium, size: 16))
                    
                    RoundedRectangle(cornerRadius: 1)
                        .frame(height: 0.5)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                }
                .foregroundStyle(.specialDarkGrey)
                
                HStack(spacing: 24) {
                    Circle()
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.white)
                        .overlay {
                            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .icon, state: .normal)) {
                                Task {
                                    do {
                                        try await vm.continueWithGoogle()
                                        showMainScreen = false
                                        showWelcomeScreen = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                showMainScreen = true
                                            }
                                        }
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            
                        }
                    Button {
                        //apple signin flow
                        Task {
                            do {
                                try await vm.continueWithApple()
                                showMainScreen = false
                                showWelcomeScreen = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showMainScreen = true
                                    }
                                }
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Circle()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(.white)
                            .overlay {
                                Image(systemName: "applelogo")
                                    .foregroundStyle(.black)
                                    .imageScale(.large)
                                    .offset(x: -0.5)
                            }
                    }
                    
                    Button {
                        Task {
                            do {
                                try await vm.continueAnounimously()
                                showMainScreen = false
                                showWelcomeScreen = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showMainScreen = true
                                    }
                                }
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Circle()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(.white)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.black)
                                    .imageScale(.large)
                                    .offset(x: -0.5)
                            }
                    }
                    
                }
                .padding(.vertical, 4)
                
                Text("Login")
                    .foregroundStyle(.specialBlack)
                    .font(.custom(Constants.appFontBold, size: 24))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(.specialGreen)
                    .clipShape(.rect(cornerRadius: 26))
                    .asButton(.tap) {
                        Task {
                            do {
                                try await vm.signIn()
                                showMainScreen = false
                                showWelcomeScreen = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showMainScreen = true
                                    }
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
                
                HStack {
                    Text("Don't have an account?")
                        .font(.callout)
                        .foregroundStyle(.specialWhite)
                    
                    NavigationLink {
                        SignUpView(showWelcomeScreen: $showWelcomeScreen, showMainScreen: $showMainScreen)
                    } label: {
                        Text("Sign Up")
                            .foregroundStyle(.specialGreen)
                            .underline()
                            .padding(8)
                            .background(.black.opacity(0.000001))
                            .offset(x: -4)
                    }
                }
                .font(.custom(Constants.appFontMedium, size: 16))
                
            }
            .padding(.horizontal, 16)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationStack {
        WelcomeView(showWelcomeScreen: .constant(true), showMainScreen: .constant(true))
    }
}


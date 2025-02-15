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
        try await AuthenticationManager.shared.signInAnonymous()
    }
}

struct WelcomeView: View {
    
//    @State private var animateLogo: Bool = false
    @State private var animateSymbol: Bool = false
    
    @Binding var showWelcomeScreen: Bool
    
    @StateObject private var vm: WelcomeViewModel = WelcomeViewModel()
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ZStack {
                
                logoCell
                
                VStack {
                    Spacer()
                    
                    
                    TextField("Email...", text: $vm.emailText)
                        .padding()
                        .background(.specialBlack)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(lineWidth: 3)
                                .foregroundStyle(.specialDarkGrey)
                        }
                    
                    SecureField("Password...", text: $vm.passwordText)
                        .padding()
                        .background(.specialBlack)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(lineWidth: 3)
                                .foregroundStyle(.specialDarkGrey)
                        }
                    
                    Text("Sign In")
                        .foregroundStyle(.specialBlack)
                        .font(.title)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(.specialYellow)
                        .clipShape(.rect(cornerRadius: 16))
                        .padding(.top, 16)
                        .asButton(.tap) {
                            Task {
                                do {
                                    try await vm.signIn()
                                    
                                    showWelcomeScreen = false
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
                            SignUpView(showWelcomeScreen: $showWelcomeScreen)
                        } label: {
                            Text("Register")
                                .foregroundStyle(.blue)
                                .padding(8)
                                .background(.black.opacity(0.000001))
                                .offset(x: -4)
                        }
                    }
                    .padding(.top, 8)
                    .font(.callout)
                    HStack(spacing: 24) {
                        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .icon, state: .normal)) {
                            Task {
                                do {
                                    try await vm.continueWithGoogle()
                                    showWelcomeScreen = false
                                } catch {
                                    print(error)
                                }
                            }
                        }
                        .clipShape(.circle)
                        
                        Button {
                            //apple signin flow
                            Task {
                                do {
                                    try await vm.continueWithApple()
                                } catch {
                                    print(error)
                                }
                            }
                        } label: {
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.black)
                                .overlay {
                                    Image(systemName: "applelogo")
                                        .foregroundStyle(.white)
                                        .imageScale(.large)
                                        .offset(x: -0.5)
                                }
                        }
                        
                        Button {
                            Task {
                                do {
                                    try await vm.continueAnounimously()
                                    showWelcomeScreen = false
                                } catch {
                                    print(error)
                                }
                            }
                        } label: {
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.specialYellow)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.specialDarkGrey)
                                        .imageScale(.large)
                                        .offset(x: -0.5)
                                }
                        }
                    }
                    
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                //.frame(maxHeight: .infinity, alignment: .bottom)
                //.background(.red)
            }
            //.background(.red)
        }
        .preferredColorScheme(.dark)
    }
    
    private var logoCell: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 5)
                    .frame(width: 180, height: 180)
                    .foregroundStyle(.specialWhite.opacity(0.5))
                
                Circle()
                    .frame(width: 180, height: 180)
                    .foregroundStyle(.black)
                VStack {
                    Text("CookIt!")
                        .font(.largeTitle)
                        .foregroundStyle(.specialWhite)
                        .fontWeight(.bold)
                    ZStack {
                        Image(systemName: "fork.knife")
                            .opacity(animateSymbol ? 1 : 0)
                            .rotationEffect(Angle(degrees: animateSymbol ? 0 : -90))
                        Image(systemName: "frying.pan")
                            .opacity(animateSymbol ? 0 : 1)
                            .rotationEffect(Angle(degrees: animateSymbol ? 90 : 0))
                    }
                    .fontWeight(.semibold)
                    .font(.largeTitle)
                    .imageScale(.large)
                    .foregroundStyle(.specialYellow)
                    .onAppear() {
                        withAnimation(.easeInOut(duration: 0.3).delay(15.0).repeatForever()) {
                            animateSymbol.toggle()
                        }
                    }
                }
                .offset(x: 1, y: 10)
            }
        }
        .transition(.move(edge: .top))
        .padding(.top, 24)
        .frame(maxHeight: .infinity, alignment: .top)
        //.background(.red)
    }
}

#Preview {
    NavigationStack {
        WelcomeView(showWelcomeScreen: .constant(true))
    }
}


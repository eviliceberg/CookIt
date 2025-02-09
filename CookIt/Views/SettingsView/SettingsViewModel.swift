//
//  SettingsViewModel.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-09.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var confirmPassword: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var authUser: AuthDataResultModel? = nil
    @Published var providers: [AuthProviderOption] = []
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func loadProviders() throws {
        providers = try AuthenticationManager.shared.getProviders()
    }
    
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func deleteAccount() async throws {
        //let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        try await AuthenticationManager.shared.deleteAccount()
    }
    
    func resetPassword() async throws {
        guard let userEmail = authUser?.email else {
            throw CookItErrors.noData
        }
        try await AuthenticationManager.shared.resetPassword(email: userEmail)
    }
    
    func updatePassword(newPassword: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: newPassword)
    }
    
    func updateEmail(newEmail: String) async throws {
        try await AuthenticationManager.shared.updateEmail(email: newEmail)
    }
    
    func linkGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        self.authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
        if let authUser {
            let user = DBUser(auth: authUser)
            try await UserManager.shared.createNewUser(user: user)
        }
    }
    
    func linkEmail() async throws {
        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
        if let authUser {
            let user = DBUser(auth: authUser)
            try await UserManager.shared.createNewUser(user: user)
        }
    }
    
    func linkApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        self.authUser = try await AuthenticationManager.shared.linkApple(token: tokens)
        if let authUser {
            let user = DBUser(auth: authUser)
            try await UserManager.shared.createNewUser(user: user)
        }
    }
    
}

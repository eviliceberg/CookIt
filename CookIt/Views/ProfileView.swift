//
//  ProfileView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-11.
//

import SwiftUI
import SwiftfulUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authUser.uid)
    }
    
}

struct ProfileView: View {
    
    @Binding var showWelcomeScreen: Bool
    
    @StateObject private var vm: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            if let user = vm.user {
                ScrollView(.vertical) {
                    if let photoUrl = user.photoUrl {
                        Rectangle()
                            .opacity(0)
                            .overlay(content: {
                                ImageLoaderView(urlString: photoUrl)
                            })
                            .asStretchyHeader(startingHeight: 400)
                        
                        VStack(alignment: .leading) {
                            Text(user.name ?? "None")
                            Text(user.userId)
                            Text("Is Anonimous: \(user.isAnonymous ?? true)")
                            Text("Is Premium: \(user.isPremium ?? false)")
                        }
                        .padding(.horizontal, 8)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                }
                .ignoresSafeArea()
            }
        }
        .onFirstAppear {
            Task {
                try await vm.loadCurrentUser()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView(showWelcomeScreen: $showWelcomeScreen)
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showWelcomeScreen: .constant(false))
    }
}

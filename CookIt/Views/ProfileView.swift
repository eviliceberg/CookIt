//
//  ProfileView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-11.
//

import SwiftUI
import SwiftfulUI
import SwiftfulRouting

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
    @Environment(\.router) var router
    @StateObject private var vm: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            if let user = vm.user {
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        Rectangle()
                            .opacity(0)
                            .overlay(content: {
                                if let photoUrl = user.photoUrl {
                                    ImageLoaderView(urlString: photoUrl)
                                } else {
                                    Image(.user)
                                }
                            })
                            .asStretchyHeader(startingHeight: 400)

                        Text(user.name ?? "None")
                        Text(user.userId)
                        Text("Is Anonimous: \(user.isAnonymous ?? true)")
                        Text("Is Premium: \(user.isPremium ?? false)")
                    }
                    .padding(.horizontal, 8)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("To the animation testing playground")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundStyle(.specialBlack)
                        .background(.white)
                        .clipShape(.rect(cornerRadius: 16))
                        .asButton(.tap) {
                            router.showScreen(.push) { _ in
                                AnimationLogoView()
                            }
                        }
                    
                    Text("To the photo testing playground")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundStyle(.specialBlack)
                        .background(.white)
                        .clipShape(.rect(cornerRadius: 16))
                        .asButton(.tap) {
                            router.showScreen(.push) { _ in
                                UploadTestView()
                            }
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
                Image(systemName: "gear")
                    .foregroundStyle(.specialWhite)
                    .asButton {
                        router.showScreen(.push) { _ in
                            SettingsView(showWelcomeScreen: $showWelcomeScreen)
                        }
                    }
//                NavigationLink {
//                    
//                } label: {
//                    
//                }
            }
        }
    }
}

#Preview {
    RouterView { _ in
        ProfileView(showWelcomeScreen: .constant(false))
    }
}

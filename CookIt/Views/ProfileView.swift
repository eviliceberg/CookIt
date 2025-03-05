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
    
    @Published var user: DBUser
    @Published var savesCount: Int = 0
    
    func getSavesCount() async {
        do {
            self.savesCount = try await UserManager.shared.getFavoritesCount(userId: user.userId)
        } catch {
            print(error)
        }
    }
    
    init(user: DBUser) {
        self.user = user
    }
}

struct ProfileView: View {
    
    @Binding var showWelcomeScreen: Bool
    @Environment(\.router) var router
    @StateObject private var vm: ProfileViewModel
    
    init(user: DBUser, showWelcomeScreen: Binding<Bool>) {
        _vm = StateObject(wrappedValue: ProfileViewModel(user: user))
        self._showWelcomeScreen = showWelcomeScreen
    }
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 8, pinnedViews: [.sectionHeaders]) {
                    Section {
                        
                        topSection
                            .padding(.top, 16)
                            
                        
                    } header: {
                        ReusableHeader(systemName: "chevron.left", title: "", router: router)
                    }
                }
            }
            .clipped()
            .ignoresSafeArea(.all, edges: .bottom)
            .scrollIndicators(.hidden)
        }
        .task {
            await vm.getSavesCount()
        }
    }
    
    private var topSection: some View {
        HStack(spacing: 16) {
            if let photo = vm.user.photoUrl {
                ImageLoaderView(urlString: photo)
                    .frame(width: 100, height: 100)
                    .clipShape(.circle)
            } else {
                Image(.user)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(.circle)
            }
            
            VStack(alignment: .leading, spacing: -2) {
                Text(vm.user.name ?? "User")
                    .font(.custom(Constants.appFontBold, size: 24))
                    .foregroundStyle(.specialWhite)
                
                HStack(spacing: 8) {
                    Text("0 recipes")
                    
                    Text("\(vm.savesCount) likes")
                }
                .font(.custom(Constants.appFontMedium, size: 16))
                .foregroundStyle(.specialWhite)
                HStack(spacing: 2) {
                    Image(systemName: "at")
                    Text(vm.user.username)
                }
                .foregroundStyle(.specialGreen)
                .font(.custom(Constants.appFontMedium, size: 16))
            }
        }
        .padding(.horizontal, 16)
    }
    
}
    
#Preview {
    RouterView { _ in
        ProfileView(user: DBUser(userId: "1", isAnonymous: true, name: "Mock User", username: "Black_Gorilla224"), showWelcomeScreen: .constant(false))
    }
}

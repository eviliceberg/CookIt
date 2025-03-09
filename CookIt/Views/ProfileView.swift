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
    @Published var authUser: AuthDataResultModel? = nil
    @Published var email: String = ""
    @Published var password: String = ""
    
    func getSavesCount() async {
        do {
            self.savesCount = try await UserManager.shared.getFavoritesCount(userId: user.userId)
        } catch {
            print(error)
        }
    }
    
    func logOut() async throws {
        try AuthenticationManager.shared.signOut()
        
        if user.isAnonymous == true {
            try await UserManager.shared.deleteUser(userId: user.userId)
        }
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.deleteAccount()
        try await UserManager.shared.deleteUser(userId: user.userId)
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
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
    
    init(user: DBUser) {
        self.user = user
    }
}

struct ProfileView: View {
    
    @Binding var showWelcomeScreen: Bool
    @Environment(\.router) var router
    @StateObject private var vm: ProfileViewModel
    
    @State private var showEmailAlert: Bool = false
    
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
                         
                        if let userInfo = vm.user.userInfo {
                            Text(userInfo)
                                .font(.system(.callout, design: .rounded))
                                .font(.system(size: 16))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Account")
                                .foregroundStyle(.specialWhite)
                                .font(.custom(Constants.appFontBold, size: 20))
                                .padding(.bottom, 8)
                            
                            
                            if vm.user.isAnonymous == true {
                                Text("Link Email")
                                    .font(.custom(Constants.appFontMedium, size: 14))
                                    .foregroundStyle(.specialWhite)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.black.opacity(0.000001))
                                    .onTapGesture {
                                        showEmailAlert = true
                                    }
                                
                                Divider()
                                
                                Text("Link Apple")
                                    .font(.custom(Constants.appFontMedium, size: 14))
                                    .foregroundStyle(.specialWhite)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.black.opacity(0.000001))
                                    .onTapGesture {
                                        Task {
                                            try await vm.linkApple()
                                        }
                                    }
                                
                                Divider()
                                
                                Text("Link Google")
                                    .font(.custom(Constants.appFontMedium, size: 14))
                                    .foregroundStyle(.specialWhite)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.black.opacity(0.000001))
                                    .onTapGesture {
                                        Task {
                                            try await vm.linkGoogle()
                                        }
                                    }
                                
                                Divider()
                            }
                            
                            Text("Log Out")
                                .font(.custom(Constants.appFontMedium, size: 14))
                                .foregroundStyle(.specialWhite)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.black.opacity(0.000001))
                                .onTapGesture {
                                    Task {
                                        try await vm.logOut()
                                        showWelcomeScreen = true
                                    }
                                }
                            
                            Divider()
                            
                            Text("Delete Account")
                                .font(.custom(Constants.appFontMedium, size: 16))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.black.opacity(0.000001))
                                .onTapGesture {
                                    Task {
                                        try await vm.deleteAccount()
                                        showWelcomeScreen = true
                                    }
                                }
                        }
                        .padding(.horizontal, 16)
                        
                    } header: {
                        ReusableHeader(systemName: "chevron.left", title: "", router: router)
                    }
                }
            }
            .clipped()
            .ignoresSafeArea(.all, edges: .bottom)
            .scrollIndicators(.hidden)
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .task {
            vm.loadAuthUser()
            await vm.getSavesCount()
        }
        .alert("Enter email and password.", isPresented: $showEmailAlert) {
            TextField("Email...", text: $vm.email)
            SecureField("Password...", text: $vm.password)
            Button("Done") {
                if vm.email.isEmpty || vm.password.isEmpty {
                    vm.email = ""
                    vm.password = ""
                    let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                    impactMed.impactOccurred()
                } else {
                    Task {
                        do {
                            try await vm.linkEmail()
                            showEmailAlert = false
                            vm.email = ""
                            vm.password = ""
                        } catch {
                            print(error)
                        }
                    }
                }
            }
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
                    Text("Some Social")
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
        ProfileView(user: DBUser(userId: "1", isAnonymous: true, name: "Mock User"), showWelcomeScreen: .constant(false))
    }
}

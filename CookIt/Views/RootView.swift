//
//  RootView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-06.
//

import SwiftUI
import SwiftfulRouting

struct RootView: View {
    
    @State private var showWelcomeView: Bool = false
    
    @State private var showMainScreen: Bool = false
    @StateObject var vm: HomeViewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            if !showWelcomeView {
                Group {
                    if showMainScreen {
                        RouterView { _ in
                            HomeView(showWelcomeView: $showWelcomeView)
                        }
                    } else {
                        SplashView()
                    }
                }
                .environmentObject(vm)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            showWelcomeView = authUser == nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showMainScreen = true
                }
            }
        }
        .fullScreenCover(isPresented: $showWelcomeView) {
            NavigationStack {
                WelcomeView(showWelcomeScreen: $showWelcomeView)
            }
        }
    }
}

#Preview {
    RouterView { _ in
        RootView()
    }
}

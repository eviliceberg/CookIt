//
//  RootView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-06.
//

import SwiftUI

struct RootView: View {
    
    @State private var showWelcomeView: Bool = false
    
    var body: some View {
        ZStack {
            if !showWelcomeView {
                TabBarView(showWelcomeScreen: $showWelcomeView)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            showWelcomeView = authUser == nil
        }
        .fullScreenCover(isPresented: $showWelcomeView) {
            NavigationStack {
                WelcomeView(showWelcomeScreen: $showWelcomeView)
            }
        }
    }
}

#Preview {
    RootView()
}

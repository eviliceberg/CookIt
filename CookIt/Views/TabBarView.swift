//
//  TabBarView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-10.
//

import SwiftUI

struct TabBarView: View {
    
    @Binding var showWelcomeScreen: Bool
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Discover", systemImage: "globe", value: 0) {
                NavigationStack {
                    DiscoverView()
                }
            }
            Tab("Profile", systemImage: "person.fill", value: 1) {
                NavigationStack {
                    SettingsView(showWelcomeScreen: $showWelcomeScreen)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    //NavigationStack {
        TabBarView(showWelcomeScreen: .constant(false))
    //}
}

//
//  SettingsView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-08.
//

import SwiftUI

final class SettingsViewModel: ObservableObject {
    
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
}

struct SettingsView: View {
    
    @StateObject private var vm = SettingsViewModel()
    
    @Binding var showWelcomeScreen: Bool
    
    var body: some View {
        List {
            Button {
                do {
                    try vm.logOut()
                    showWelcomeScreen = true
                } catch {
                    print(error)
                }
            } label: {
                Text("Log Out")
            }

        }
    }
}

#Preview {
    SettingsView(showWelcomeScreen: .constant(false))
}

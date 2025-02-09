//
//  SettingsView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-08.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var vm = SettingsViewModel()
    
    @Binding var showWelcomeScreen: Bool
    
    @State private var showEmailAlert: Bool = false
    
    var body: some View {
            VStack {
                List {
                    if let user = vm.authUser {
                        Text(user.name ?? "None")
                        Text(user.isAnonymous.description)
                        Text(user.uid)
                    }
                    
                    
                    if vm.authUser?.isAnonymous == true {
                        linkAccountSection
                    }
                    
                    Section {
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
                        Button(role: .destructive) {
                            Task {
                                do {
                                    try await vm.deleteAccount()
                                    showWelcomeScreen = true
                                } catch {
                                    print(error)
                                }
                            }
                        } label: {
                            Text("Delete Account")
                        }
                    }
                    
                }
            }
            .onAppear(perform: {
                vm.loadAuthUser()
            })
            .alert("Enter email and password.", isPresented: $showEmailAlert) {
                TextField("Email...", text: $vm.email)
                SecureField("Password...", text: $vm.password)
                Button("Done") {
                    if vm.email.isEmpty || vm.password.isEmpty {
                        vm.email = ""
                        vm.password = ""
                    } else {
                        Task {
                            do {
                                try await vm.linkEmail()
                                showEmailAlert = false
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
    }
    
    private var linkAccountSection: some View {
        Section {
            Button {
                showEmailAlert = true
            } label: {
                Text("Link Email")
            }
            
            Button {
                Task {
                    do {
                        try await vm.linkGoogle()
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Link Google")
            }
            Button {
                Task {
                    do {
                        try await vm.linkApple()
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Link Apple")
            }
        }
    }
}

#Preview {
    SettingsView(showWelcomeScreen: .constant(false))
}

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
    @State private var updatePassword: Bool = false
    @State private var updateEmail: Bool = false
    
    var body: some View {
            VStack {
                List {
                    if vm.providers.contains(.email) {
                        emailFunctionsSection
                            .listRowBackground(Color.specialBlack)
                    }
                    
                    
                    if vm.authUser?.isAnonymous == true {
                        linkAccountSection
                            .listRowBackground(Color.specialBlack)
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
                    .listRowBackground(Color.specialBlack)
                }
                .background(.specialBlack)
                .listStyle(.automatic)
            }
            .preferredColorScheme(.dark)
            .onAppear(perform: {
                vm.loadAuthUser()
                try? vm.loadProviders()
            })
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
            .alert("Enter new email.", isPresented: $updateEmail) {
                TextField("Enter email...", text: $vm.email)
                Button("Done") {
                    if !vm.email.isEmpty {
                        Task {
                            do {
                                try await vm.updateEmail(newEmail: vm.email)
                                vm.email = ""
                                updateEmail = false
                            } catch {
                                print(error)
                            }
                        }
                    } else {
                        let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                        impactMed.impactOccurred()
                    }
                    
                }
            }
            .alert("Enter new password", isPresented: $updatePassword) {
                SecureField("Enter new password...", text: $vm.password)
                SecureField("Confirm your new password...", text: $vm.confirmPassword)
                Button("Done") {
                    if !vm.password.isEmpty && !vm.confirmPassword.isEmpty && vm.password == vm.confirmPassword {
                            Task {
                                do {
                                    try await vm.updatePassword(newPassword: vm.password)
                                    vm.password = ""
                                    vm.confirmPassword = ""
                                    updatePassword = false
                                } catch {
                                    print(error)
                                }
                            }
                        } else {
                            vm.confirmPassword = ""
                            let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                            impactMed.impactOccurred()
                        }
                    }
            }
    }
    
    private var emailFunctionsSection: some View {
        Section {
            Button("Reset Password") {
                Task {
                    do {
                        try await vm.resetPassword()
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Update Password") {
                updatePassword = true
            }
            
            Button("Update Email") {
                updateEmail = true
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

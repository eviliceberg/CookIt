//
//  ContentView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-06.
//

import SwiftUI
import SwiftfulUI
import GoogleSignIn
import GoogleSignInSwift

struct WelcomeView: View {
    
    @State private var animateLogo: Bool = false
    @State private var animateSymbol: Bool = false
    
    @State private var emailText: String = ""
    @State private var passwordText: String = ""
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ZStack {
                if animateLogo {
                    logoCell
                }
                VStack {
                    TextField("Email...", text: $emailText)
                        .padding()
                        .background(.specialWhite.opacity(0.7))
                        .clipShape(.rect(cornerRadius: 16))
                    
                    SecureField("Password...", text: $emailText)
                        .padding()
                        .background(.specialWhite.opacity(0.7))
                        .clipShape(.rect(cornerRadius: 16))
                    
                    Text("Sign In")
                        .foregroundStyle(.specialBlack)
                        .font(.title)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(.specialYellow)
                        .clipShape(.rect(cornerRadius: 16))
                        .padding(.top, 16)
                        .asButton(.tap) {
                            
                        }
                        
                    
                }
                .padding(.horizontal, 16)
                .frame(maxHeight: .infinity, alignment: .bottom)
                //.background(.red)
            }
        }
        .animation(.easeInOut(duration: 2.0), value: animateLogo)
        .onFirstAppear {
            animateLogo = true
        }
        
    }
    
    private var logoCell: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 5)
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.specialWhite.opacity(0.5))
                
                Circle()
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.black)
                VStack {
                    Text("CookIt!")
                        .font(.largeTitle)
                        .foregroundStyle(.specialWhite)
                        .fontWeight(.bold)
                    ZStack {
                        Image(systemName: "fork.knife")
                            .opacity(animateSymbol ? 1 : 0)
                            .rotationEffect(Angle(degrees: animateSymbol ? 0 : -90))
                        Image(systemName: "frying.pan")
                            .opacity(animateSymbol ? 0 : 1)
                            .rotationEffect(Angle(degrees: animateSymbol ? 90 : 0))
                    }
                    .fontWeight(.semibold)
                    .font(.largeTitle)
                    .imageScale(.large)
                    .foregroundStyle(.specialYellow)
                    .onAppear() {
                        withAnimation(.easeInOut(duration: 0.3).delay(15.0).repeatForever()) {
                            animateSymbol.toggle()
                        }
                    }
                }
                .offset(y: 8)
            }
        }
        .transition(.move(edge: .top))
        .padding(.top, 32)
        .frame(maxHeight: .infinity, alignment: .top)
        //.background(.red)
    }
}

#Preview {
    WelcomeView()
}


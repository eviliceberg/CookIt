//
//  AnimationLogoView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-18.
//

import SwiftUI

struct AnimationLogoView: View {
    
    @State private var animate: Bool = false
    @State private var animateThird: Bool = false
    @State private var animateTitle: Bool = false
    @State private var animateFifth: Bool = false
    
    @State private var text: String = "Cook and enjoy!"
    @State private var textColor: Color = .specialGreen
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Image(.first)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .offset(y: animateFifth ? -107 : (animateThird ? -75 : (animate ? -44 : -22)))
                    .animation(.bouncy(duration: 0.3), value: animate)
                    .animation(.bouncy(duration: 0.3), value: animateFifth)
                    .animation(.bouncy(duration: 0.3), value: animateThird)
                //first -22
                //Second -44
                //third -75
                //Forth -107
                
                VStack(spacing: 0) {
                    if animate {
                        Image(.second)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .offset(y: animateFifth ? -63 : (animateThird ? -31 : 0))
                    }
                }
                .animation(.bouncy(duration: 0.3), value: animate)
                .animation(.bouncy(duration: 0.3), value: animateFifth)
                .animation(.bouncy(duration: 0.3), value: animateThird)
                //Second 0
                //third -31
                //forth -63
                
                VStack(spacing: 0) {
                    if animateThird {
                    Image(.third)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .offset(y: animateFifth ? -30 : 0)
                    }
                }
                .animation(.bouncy(duration: 0.3), value: animateThird)
                .animation(.bouncy(duration: 0.3), value: animateFifth)
                //third 0
                //forth -30

                VStack(spacing: 0) {
                    if animateTitle {
                    Image(.cookIt)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                    }
                }
                .animation(.bouncy(duration: 0.3), value: animateTitle)

                VStack(spacing: 0) {
                    if animateFifth {
                    Image(.fifth)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .offset(y: animateTitle ? 35 : 0)
                    }
                }
                .animation(.bouncy(duration: 0.3), value: animateFifth)
                .animation(.bouncy(duration: 0.3), value: animateTitle)
                //forth 0
                //last 35
    
                Image(.sixth)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 230)
                    .offset(y: animateTitle ? 70 : (animateFifth ? 35 : (animate ? 35 : 22)))
                    .animation(.bouncy(duration: 0.3), value: animate)
                    .animation(.bouncy(duration: 0.3), value: animateFifth)
                    .animation(.bouncy(duration: 0.3), value: animateTitle)
            }
            //first 22
            //second 35
            //third 35
            //forth 35
            //last 70
            // animateTitle ? 70 : (animateForth ? 35 : (animate ? 35 : 22))
//            Text(text)
//                .font(.custom(Constants.appFontSemiBold, size: 24))
//                .foregroundStyle(textColor)
//                .opacity(animateTitle ? 0 : 1)
 
            
            Button("click") {
                animate = true
                text = "Mix it up!"
                textColor = .specialPink
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    animateThird = true
                    text = "Save your recipe"
                    textColor = .specialYellow
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    animateFifth = true
                    text = "Add ingredients"
                    textColor = .specialLightBlue
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                    animateTitle = true
                }
            }
            .animation(.smooth, value: text)
            .padding(.top, 64)
        }
    }
}

#Preview {
    ZStack {
        Color.specialBlack.ignoresSafeArea()
        
        AnimationLogoView()
    }
}

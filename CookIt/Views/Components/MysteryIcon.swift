//
//  MysteryIcon.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-16.
//

import SwiftUI

struct MysteryIcon: View {
    
    var symbol: String = "?"
    var size: CGFloat = 32
    
    var body: some View {
        ZStack {
            Text(symbol)
                .font(.system(size: size, weight: .semibold, design: .rounded))
            
            Text(symbol)
                .font(.system(size: size*0.55, weight: .semibold, design: .rounded))
                .opacity(0.4)
                .rotationEffect(Angle(degrees: -32.26))
                //.scaleEffect(0.8)
                .offset(x: -10, y: -0.5)
            
            Text(symbol)
                .font(.system(size: size*0.55, weight: .semibold, design: .rounded))
                .opacity(0.4)
                .rotationEffect(Angle(degrees: 23.71))
                //.scaleEffect(0.8)
                .offset(x: 10, y: 5)
        }
        .foregroundStyle(.specialBlack)
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
        .background(.specialPink)
        .clipShape(.rect(cornerRadius: 40))
    }
}

#Preview {
    ZStack {
        Color.specialBlack.ignoresSafeArea()
        
        MysteryIcon()
    }
}

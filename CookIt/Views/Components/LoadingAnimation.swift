//
//  LoadingAnimation.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-19.
//

import SwiftUI

struct LoadingAnimation: View {
    
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    @State private var redPoints: [CGPoint] = [
        CGPoint(x: 180.0, y: 320.0),
        CGPoint(x: 205.0, y: 295.0),
        CGPoint(x: 225.0, y: 315.0),
        CGPoint(x: 235.0, y: 340.0),
        CGPoint(x: 250.0, y: 370.0),
        CGPoint(x: 245.0, y: 400.0),
        CGPoint(x: 225.0, y: 420.0),
        CGPoint(x: 205.0, y: 430.0),
        CGPoint(x: 185.0, y: 420.0),
        CGPoint(x: 170.0, y: 400.0),
        CGPoint(x: 160.0, y: 370.0),
        CGPoint(x: 170.0, y: 335.0)
    ]

    @State private var orangePoints: [CGPoint] = [
        CGPoint(x: 170.0, y: 150.0),
        CGPoint(x: 155.0, y: 130.0),
        CGPoint(x: 145.0, y: 110.0),
        CGPoint(x: 135.0, y: 85.0),
        CGPoint(x: 140.0, y: 55.0),
        CGPoint(x: 160.0, y: 40.0),
        CGPoint(x: 180.0, y: 20.0),
        CGPoint(x: 195.0, y: 35.0),
        CGPoint(x: 210.0, y: 55.0),
        CGPoint(x: 220.0, y: 85.0),
        CGPoint(x: 210.0, y: 115.0),
        CGPoint(x: 190.0, y: 130.0)
    ]

    @State private var greenPoints: [CGPoint] = [
        CGPoint(x: 220.0, y: -50.0),
        CGPoint(x: 205.0, y: -30.0),
        CGPoint(x: 185.0, y: -50.0),
        CGPoint(x: 170.0, y: -70.0),
        CGPoint(x: 160.0, y: -95.0),
        CGPoint(x: 175.0, y: -130.0),
        CGPoint(x: 190.0, y: -150.0),
        CGPoint(x: 205.0, y: -165.0),
        CGPoint(x: 225.0, y: -150.0),
        CGPoint(x: 240.0, y: -130.0),
        CGPoint(x: 250.0, y: -105.0),
        CGPoint(x: 240.0, y: -75.0)
    ]

    @State private var endScale: CGFloat = 1.0
    @State private var count: Int = 0
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            VStack(spacing: 10) {
                RadialGradient(colors: [.red.opacity(0.8), .specialBlack.opacity(0.000001)], center: .center, startRadius: 7 * endScale, endRadius: 40 * endScale)
                    .position(redPoints[count])
                
                RadialGradient(colors: [.orange.opacity(0.8), .specialBlack.opacity(0.000001)], center: .center, startRadius: 2 * endScale, endRadius: 30 * endScale)
                    .position(orangePoints[count])
                
                RadialGradient(colors: [.specialGreen.opacity(0.8), .specialBlack.opacity(0.000001)], center: .center, startRadius: 1 * endScale, endRadius: 25 * endScale)
                    .position(greenPoints[count])
                
            }
            .onReceive(timer) { _ in
                withAnimation(.spring(response: 1.0, dampingFraction: 0.7, blendDuration: 0.25)) {
                    if count >= 11 {
                        count = 0
                    } else {
                        count += 1
                        endScale += 0.05
                    }
                    if count % 5 == 0 {
                        endScale = 1.3
                    } else {
                        endScale = 1.0
                    }
                    
                }
            }
        }
    }
}

#Preview {
    LoadingAnimation()
}

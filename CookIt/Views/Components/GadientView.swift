//
//  GadientView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-17.
//

import SwiftUI

struct GadientView: View {
    
    var cornerRadius: CGFloat = 20
    
    @State private var rotation: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .foregroundStyle(LinearGradient(colors: [.red, .orange, .yellow, .green, .specialLightBlue, .blue, .purple], startPoint: .top, endPoint: .bottom))
                    .rotationEffect(Angle(degrees: rotation))
                    .scaleEffect((geo.size.width * 2) / geo.size.height)
                    .mask {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(lineWidth: 2)
                            .frame(width: geo.size.width - 2, height: geo.size.height - 2)
                    }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
        //.background(.red)
    }
}

#Preview {
    VStack {
        Text("Hello World hvfkjhv ")
            .padding()
            .overlay {
                GadientView()
            }
    }
    .padding(.horizontal, 16)
    
    
}

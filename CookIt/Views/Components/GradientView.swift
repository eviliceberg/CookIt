//
//  GadientView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-17.
//

import SwiftUI

struct GradientView: View {
    
    var cornerRadius: CGFloat = 20
    
    @State private var rotation: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .foregroundStyle(LinearGradient(colors: [.red, .orange, .yellow, .green, .specialLightBlue, .blue, .purple], startPoint: .top, endPoint: .bottom))
                    .rotationEffect(Angle(degrees: rotation))
                    .scaleEffect(geo.size.width > geo.size.height ? (geo.size.width / geo.size.height) : (geo.size.height / geo.size.width))
                    .mask {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(lineWidth: 2)
                            .frame(width: geo.size.width - 2, height: geo.size.height - 2)
                    }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
        //.background(.red)
    }
}

#Preview {
    ScrollView {
        VStack {
            Text("Text 1")
            Text("Hello World hvfkjhvgfkgfkgfkgfkhfkffkfhfkhjfhfjfjfhfkfhfjhfjkfkhfkhfhfhfhfkhfkjfjkfhjfjffjfhjfjkfkjfhjfkjkjfkfhjfjhfkjfjhjkhfjfkfhkfhjffkjhf ")
                .padding()
                .overlay {
                    GradientView()
                }
            Text("Text 2")
        }
    }
    .padding(.horizontal, 16)
    
    
}

//
//  RecipeCellView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-10.
//

import SwiftUI

struct RecipeCellView: View {
    
    var title: String = "Dish Name"
    var isPremium: Bool = false
    var imageURL: String = Constants.randomImage
    var height: CGFloat = 250
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ImageLoaderView(urlString: imageURL)
                
            HStack(alignment: .bottom) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.specialWhite)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isPremium {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.specialYellow)
                        .font(.title2)
                        .padding([.bottom, .trailing])
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [.specialBlack.opacity(0.1), .specialBlack.opacity(0.4), .specialBlack.opacity(0.4)], startPoint: .top, endPoint: .bottom)
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(.rect(cornerRadius: 32))
    }
}

#Preview {
    ZStack {
        Color.specialBlack.ignoresSafeArea()
        VStack {
            RecipeCellView(isPremium: true)
                .padding(.horizontal, 16)
        }
    }
}

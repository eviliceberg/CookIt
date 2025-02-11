//
//  RecipeCellView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-10.
//

import SwiftUI
import SwiftfulUI

struct RecipeCellView: View {
    
    var title: String = "Dish Name"
    var isPremium: Bool = false
    var imageURL: String = Constants.randomImage
    var height: CGFloat = 250
    var bookmarkPressed: (() -> Void)? = nil
    
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
                    Image(systemName: "star.fill")
                        .foregroundStyle(.specialYellow)
                        .font(.title2)
                        .opacity(isPremium ? 1 : 0)
                        .padding(.bottom, 12)
                        .padding(.trailing, 8)
                    
//                    Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
//                        .foregroundStyle(isFavorite ? .specialYellow : .specialWhite)
//                        .font(.title2)
//                        .padding(4)
//                        .background(.black.opacity(0.00001))
//                        .asButton(.tap) {
//                            bookmarkPressed?()
//                        }

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

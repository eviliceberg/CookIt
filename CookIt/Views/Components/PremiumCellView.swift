//
//  PremiumCellView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-15.
//

import SwiftUI

struct PremiumCellView: View {
    
    var imageUrl: String = Constants.randomImage
    var author: String = "Carlos Ruiz"
    var title: String = "Salmon Soup"
    var time: String = "35 min"
    
    var body: some View {
        ImageLoaderView(urlString: imageUrl)
            .frame(width: 361, height: 280)
            .clipShape(.rect(cornerRadius: 20))
            .overlay(alignment: .bottom) {
                VStack(spacing: -12) {
                    HStack {
                        Text(author)
                            .font(.custom(Constants.appFontMedium, size: 16))
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                        
                        HStack(spacing: 1) {
                            Image(systemName: "clock")
                                .imageScale(.small)
                            
                            Text(time)
                                .font(.custom(Constants.appFontMedium, size: 16))
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 64)
                    
                    Text(title)
                        .font(.custom(Constants.appFontBold, size: 35))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
                .foregroundStyle(.specialWhite)
            }
            .overlay(alignment: .topLeading) {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.specialYellow)
                        .frame(width: 24, height: 24)
                    
                    Group {
                        Text("premium ")
                            .foregroundStyle(.specialYellow)
                        +
                        Text("recipe")
                            .foregroundStyle(.specialWhite)
                    }
                    .font(.custom(Constants.appFontMedium, size: 14))
                }
                .padding(16)    
            }
    }
}

#Preview {
    PremiumCellView()
}

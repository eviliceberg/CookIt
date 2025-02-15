//
//  MostPopularCellView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-13.
//

import SwiftUI

struct MostPopularCellView: View {
    
    var statuses: [String] = ["vegan", "gluten-free"]
    var cookingTime: String = "10 min"
    var author: String = "John Doe"
    var title: String = "Guacamole"
    var imageURL: String = Constants.randomImage
    
    var body: some View {
        ZStack {
            ImageLoaderView(urlString: imageURL)
                .clipShape(.rect(cornerRadius: 20))
            
            VStack {
                HStack {
                    if !statuses.isEmpty {
                        HStack {
                            ForEach(statuses, id: \.self) { status in
                                Text(status)
                                    .font(.custom(Constants.appFontMedium, size: 10))
                                    .foregroundStyle(.specialBlack)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Constants.shared.statusColor(status))
                                    .clipShape(.rect(cornerRadius: 14))
                            }
                        }
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                        
                        Text(cookingTime)
                            .font(.custom(Constants.appFontMedium, size: 14))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    .foregroundStyle(.specialWhite)
                }
                
                VStack(alignment: .leading, spacing: -8) {
                    Text(author)
                        .font(.custom(Constants.appFontMedium, size: 12))

                    Text(title)
                        .font(.custom(Constants.appFontBold, size: 20))
                        .fontWeight(.bold)
                }
                .shadow(color: .black.opacity(0.25), radius: 4, y: 4)
                .foregroundStyle(.specialWhite)
                .frame(maxHeight: .infinity, alignment: .bottomLeading)
                .frame(maxWidth: .infinity,alignment: .leading)
                .offset(y: 8)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 320, height: 140)
    }
}

#Preview {
    ZStack {
        Color.specialBlack.ignoresSafeArea()
        
        MostPopularCellView()
            .padding(.horizontal, 16)
    }
}

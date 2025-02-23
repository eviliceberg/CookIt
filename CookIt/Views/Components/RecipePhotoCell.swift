//
//  RecipePhotoCell.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-21.
//

import SwiftUI

struct RecipePhotoCell: View {
    
    var photoURL: String = Constants.randomImage
    var statuses: [String] = ["gluten-free", "vegan", "vegetarian"]
    var isPremium: Bool = true
    var category: String = "Timeless classics"
    var cookingTime: String = "15 min"
    
    var body: some View {
        ImageLoaderView(urlString: photoURL)
            .frame(width: 361, height: 228)
            .clipShape(.rect(cornerRadius: 20))
            .overlay {
                VStack(alignment: .leading) {
                    HStack {
                        if isPremium {
                            Image(.premium)
                                .offset(y: 4)
                                .padding(.trailing, 2)
                        }
                        ForEach(statuses, id: \.self) { status in
                            Text(status)
                                .font(.custom(Constants.appFontMedium, size: 10))
                                .foregroundStyle(.specialBlack)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Constants.shared.statusColor(status))
                                .clipShape(.rect(cornerRadius: 14))
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    
                    HStack(spacing: 4) {
                        Text(category.capitalized)
                        
                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                            
                            Text(cookingTime)
                                .font(.custom(Constants.appFontSemiBold, size: 14))
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .font(.custom(Constants.appFont, size: 14))
                }
                .padding(16)
                .foregroundStyle(.specialWhite)
            }
    }
}

#Preview {
    RecipePhotoCell()
}

//
//  RecipePhotoCell.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-21.
//

import SwiftUI

struct RecipePhotoCell: View {
    
    let photoURL: String = Constants.randomImage
    let statuses: [String] = ["gluten-free", "vegan", "vegetarian"]
    let isPremium: Bool = true
    let categories: [String] = ["pasta", "pizza", "salad"]
    let cookingTime: String = "15 min"
    
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
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            if category == categories.first {
                                Text(category.description.capitalized + ", ")
                            } else if category == categories.last {
                                Text(category)
                            } else {
                                Text(category + ", ")
                            }
                                
                        }
                        
                        HStack(spacing: 0) {
                            Image(systemName: "clock")
                                .fontWeight(.semibold)
                                .font(.system(size: 12))
                            
                            Text(cookingTime)
                                .font(.custom(Constants.appFont, size: 14))
                        }
                    }
                }
                .foregroundStyle(.specialWhite)
            }
    }
}

#Preview {
    RecipePhotoCell()
}

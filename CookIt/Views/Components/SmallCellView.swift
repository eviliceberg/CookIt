//
//  SmallCellView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-15.
//

import SwiftUI

struct SmallCellView: View {
    
    var title: String = "Salmon Soup"
    var author: String = "Marie Leclerc"
    var time: String = "10 min"
    var photoUrl: String = Constants.randomImage
    var status: String = "vegetarian"
    var isPremium: Bool = false
    
    var height: CGFloat? = 184
    var width: CGFloat? = 171
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.specialLightBlack)
            .frame(width: width, height: height)
            .overlay {
                VStack(alignment: .leading, spacing: -8) {
                    ImageLoaderView(urlString: photoUrl)
                        .clipShape(.rect(cornerRadius: 16))
                        .padding(8)
                    VStack(alignment: .leading, spacing: -8) {
                        Text(title)
                            .font(.custom(Constants.appFontBold, size: 20))
                            .lineLimit(1)
                        HStack {
                            Text(author)
                                .font(.custom(Constants.appFontMedium, size: 12))
                                .lineLimit(1)
                            
                            HStack(spacing: 0) {
                                Image(systemName: "clock")
                                    .fontWeight(.semibold)
                                    .font(.system(size: 12))
                                
                                Text(time)
                                    .font(.custom(Constants.appFontMedium, size: 14))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .foregroundStyle(.specialWhite)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            }
            .overlay(alignment: .topLeading) {
                HStack {
                    if isPremium == true {
                        Image(.premium)
                            .shadow(color: .specialBlack.opacity(0.25), radius: 4, y: 4)
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.specialYellow)
                    }
                    
                    if !status.isEmpty {
                        Text(status)
                            .font(.custom(Constants.appFontMedium, size: 10))
                            .foregroundStyle(.specialBlack)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(Constants.shared.statusColor(status))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                }
                .padding(16)
            }
    }
}

#Preview {
    VStack {
        SmallCellView()
        SmallCellView(isPremium: true)
    }
}

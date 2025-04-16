//
//  CardView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-04-16.
//

import SwiftUI

struct CardView: View {
    
    var imageURL: String = Constants.randomImage
    var author: String = "Isabella Moretti"
    var statuses: [String] = ["gluten-free", "vegan", "vegetarian"]
    var title: String = "Título do Card"
    var time: CookingTime = CookingTime(timeNumber: 30, timeMeasure: .minutes)
    var description: String = "Some description to fill more space and test view"
    var rank: Float = 5.0
    var height: CGFloat = 594
    
    var body: some View {
        ImageLoaderView(urlString: imageURL)
            .clipShape(.rect(cornerRadius: 20))
            .overlay(alignment: .leading) {
                VStack(alignment: .leading) {
                    //top part
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(author)
                                .font(.custom(Constants.appFontMedium, size: 16))
                                .foregroundStyle(.specialWhite)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 2) {
                                Text(String(format: "%.1f", rank))
                                
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.specialYellow)
                                    .imageScale(.small)
                                    .offset(y: -1)
                            }
                        }
                        HStack {
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
                    }
                    Spacer()
                    //bottom part
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(title)
                                .font(.custom(Constants.appFontBold, size: 24))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            HStack(spacing: 2) {
                                Image(systemName: "clock")
                                
                                Text(time.lowDescription)
                            }
                        }
                        
                        Text(description)
                            .font(.caption)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                .font(.custom(Constants.appFontMedium, size: 16))
                .foregroundStyle(.specialWhite)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: height)
            .padding(.horizontal, 16)
    }
}


#Preview {
    ScrollView {
        VStack {
            CardView()
            CardView()
        }
    }
    
}

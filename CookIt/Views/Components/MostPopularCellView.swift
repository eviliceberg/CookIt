//
//  MostPopularCellView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-13.
//

import SwiftUI

struct MostPopularCellView: View {
    
    var statuses: [String] = ["vegan", "gluten free"]
    var cookingTime: (Int, String) = (10, "min")
    var author: String = "John Doe"
    var title: String = "Guacamole"
    var imageURL: String = Constants.randomImage
    
    func statusColor(_ status: String) -> Color {
        switch status {
        case "vegan":
                .specialYellow.opacity(0.49)
        case "vegetarian":
                .specialLightBlue.opacity(0.55)
        case "gluten free":
                .specialGreen.opacity(0.54)
        case "lactose-free":
                .specialPink.opacity(0.49)
        case "nut-free":
                .specialPurple.opacity(0.5)
        default:
                .specialWhite.opacity(0.5)
        }
    }
    
    var body: some View {
        ZStack {
            ImageLoaderView(urlString: imageURL)
                .clipShape(.rect(cornerRadius: 20))
            
            VStack {
                HStack {
                    HStack {
                        ForEach(statuses, id: \.self) { status in
                            Text(status)
                                .font(.custom("Baloo2", size: 10))
                                .foregroundStyle(.specialBlack)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(statusColor(status))
                                .clipShape(.rect(cornerRadius: 14))
                        }
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                        
                        Text("\(cookingTime.0) \(cookingTime.1)")
                            .font(.custom("Baloo2", size: 14))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    .foregroundStyle(.specialWhite)
                }
                
                VStack {
                    
                }
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

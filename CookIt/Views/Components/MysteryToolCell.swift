//
//  MysteryToolCell.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-16.
//

import SwiftUI

struct MysteryToolCell: View {
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Can't choose what to cook?")
                    .font(.custom(Constants.appFontMedium, size: 20))
                Group {
                    Text("-Try our ")
                    +
                    Text("randomizer ")
                        .foregroundStyle(.specialPink)
                    +
                    Text("tool")
                }
                .font(.custom(Constants.appFontSemiBold, size: 20))
            }
            .foregroundStyle(.specialWhite)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            MysteryIcon()
        }
    }
}

#Preview {
    ZStack {
        Color.specialBlack.ignoresSafeArea()
        
        MysteryToolCell()
    }
}

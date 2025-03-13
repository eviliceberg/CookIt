//
//  ReusableHeader.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-01.
//

import SwiftUI
import SwiftfulRouting

struct ReusableHeader: View {
    
    var systemName: String = "chevron.left"
    var title: String = "Title"
    var router: AnyRouter
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(systemName: systemName)
                .font(.custom(Constants.appFontSemiBold, size: 24))
                .asButton(.press) {
                    router.dismissScreen()
                }
            
            Text(title)
                .font(.custom(Constants.appFontSemiBold, size: 24))
                .frame(maxWidth: .infinity, alignment: .center)
            
        }
        .padding(.horizontal, 16)
        .foregroundStyle(.specialWhite)
        .background(.specialBlack)
        
    }
}

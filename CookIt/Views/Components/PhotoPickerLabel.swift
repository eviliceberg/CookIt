//
//  PhotoPickerLabel.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-14.
//

import SwiftUI

struct PhotoPickerLabel: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.specialLightBlack)
            .frame(height: 100)
            .overlay(alignment: .center) {
                VStack {
                    Image(systemName: "plus")
                        .foregroundStyle(.specialDarkGrey)
                        .imageScale(.large)
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text("Add Image")
                        .foregroundStyle(.specialLightGray)
                        .font(.custom(Constants.appFontMedium, size: 14))
                }
                .offset(y: 4)
            }
    }
}

#Preview {
    PhotoPickerLabel()
        .padding(.horizontal, 16)
}

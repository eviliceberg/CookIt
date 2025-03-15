//
//  StrokedTextfield.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-13.
//

import SwiftUI

struct StrokedTextfield: View {
    
    var systemName: ImageResource = .pen
    var placeholder: String = "Dish Title"
    var text: Binding<String>
    var lineLimit: Int? = nil
    
    var focus: FocusState<Bool>.Binding? = nil
    
    var body: some View {
        HStack {
            SuperTextField(textFieldType: .regular, placeholder:
              Text(placeholder)
                .font(.custom(Constants.appFontMedium, size: 16))
                .foregroundStyle(.specialLightGray), text: text, lineLimit: lineLimit, focusState: focus)
            
            Image(systemName)
                .resizable()
                .scaledToFit()
                .frame(width: 24)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .overlay {
            RoundedRectangle(cornerRadius: 26)
                .stroke(lineWidth: 1)
                .foregroundStyle(.specialDarkGrey)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ZStack {
        Color.specialBlack.ignoresSafeArea()
        
        StrokedTextfield(text: .constant("some title to test how big can be this textfield"))
    }
}

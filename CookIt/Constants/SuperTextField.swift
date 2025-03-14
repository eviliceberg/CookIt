//
//  SuperTextField.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-24.
//

import SwiftUI

struct SuperTextField: View {
    
    enum TextFieldType {
        case secure, regular, email
    }
    
    var textFieldType: TextFieldType = .regular
    var placeholder: Text
    @Binding var text: String
    
    var lineLimit: Int? = nil
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            switch textFieldType {
            case .secure:
                SecureField("", text: $text)
            case .email:
                TextField("", text: $text, axis: .vertical)
                    .keyboardType(.emailAddress)
            case .regular:
                TextField("", text: $text, axis: .vertical)
                    .keyboardType(.default)
                    .lineLimit(lineLimit)
            }
            
        }
    }
}

#Preview {
    SuperTextField(placeholder: Text("Some text"), text: .constant(""))
}

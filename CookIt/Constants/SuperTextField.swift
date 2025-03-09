//
//  SuperTextField.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-24.
//

import SwiftUI

struct SuperTextField: View {
    
    enum TextFieldType {
        case secure, regular
    }
    
    var textFieldType: TextFieldType = .regular
    var placeholder: Text
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            switch textFieldType {
            case .secure:
                SecureField("", text: $text)
            case .regular:
                TextField("", text: $text)
                    .keyboardType(.emailAddress)
            }
            
        }
    }
}

#Preview {
    SuperTextField(placeholder: Text("Some text"), text: .constant(""))
}

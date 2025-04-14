//
//  SuperTextField.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-24.
//

import SwiftUI

struct SuperTextField: View {
    
    enum TextFieldType {
        case secure, regular, email, keypad
    }
    
    var textFieldType: TextFieldType = .regular
    var placeholder: Text
    @Binding var text: String
    
    var lineLimit: Int? = nil
    
    var focusState: FocusState<Bool>.Binding? = nil
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            switch textFieldType {
            case .secure:
                SecureField("", text: $text)
            case .email:
                if let focusState {
                    TextField("", text: $text, axis: .vertical)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .focused(focusState)
                        .font(.custom(Constants.appFontMedium, size: 16))
                } else {
                    TextField("", text: $text, axis: .vertical)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .font(.custom(Constants.appFontMedium, size: 16))
                }
            case .regular:
                if let focusState {
                    TextField("", text: $text, axis: .vertical)
                        .autocorrectionDisabled()
                        .keyboardType(.default)
                        .lineLimit(lineLimit)
                        .focused(focusState)
                        .font(.custom(Constants.appFontMedium, size: 16))
                } else {
                    TextField("", text: $text, axis: .vertical)
                        .autocorrectionDisabled()
                        .keyboardType(.default)
                        .lineLimit(lineLimit)
                        .font(.custom(Constants.appFontMedium, size: 16))
                }
            case .keypad:
                if let focusState {
                    TextField("", text: $text, axis: .vertical)
                        .autocorrectionDisabled()
                        .keyboardType(.decimalPad)
                        .lineLimit(lineLimit)
                        .focused(focusState)
                        .font(.custom(Constants.appFontMedium, size: 16))
                } else {
                    TextField("", text: $text, axis: .vertical)
                        .autocorrectionDisabled()
                        .keyboardType(.decimalPad)
                        .lineLimit(lineLimit)
                        .font(.custom(Constants.appFontMedium, size: 16))
                }
            }
            
        }
    }
}

#Preview {
    SuperTextField(placeholder: Text("Some text"), text: .constant(""))
}

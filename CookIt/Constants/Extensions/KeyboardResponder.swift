//
//  ViewController+Ext.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-25.
//

import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
    
    @Published var currentHeight: CGFloat = 0
    
    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }

        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .subscribe(on: RunLoop.main)
            .assign(to: \.currentHeight, on: self)
            .store(in: &cancellableSet)
    }
}

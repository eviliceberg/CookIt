//
//  HapticManager.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-08.
//

import Foundation
import UIKit

final class HapticManager {
    
    static let shared = HapticManager()
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact() {
        let generator = UIImpactFeedbackGenerator()
        generator.impactOccurred(intensity: 0.5)
    }
    
}

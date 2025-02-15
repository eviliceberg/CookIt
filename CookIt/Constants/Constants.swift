//
//  Constants.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-10.
//

import Foundation
import SwiftUI

struct Constants {
    static let randomImage = "https://picsum.photos/600/600"
    
    static let appFont: String = "Baloo2"
    static let appFontBold: String = "Baloo2-Bold"
    static let appFontMedium: String = "Baloo2-Medium"
    static let appFontSemiBold: String = "Baloo2-SemiBold"
    
    static let shared: Constants = .init()
    
    func statusColor(_ status: String) -> Color {
        switch status {
        case "vegan":
                .specialYellow.opacity(0.49)
        case "vegetarian":
                .specialLightBlue.opacity(0.55)
        case "gluten-free":
                .specialGreen.opacity(0.54)
        case "lactose-free":
                .specialPink.opacity(0.49)
        case "nut-free":
                .specialPurple.opacity(0.5)
        default:
                .specialWhite.opacity(0.5)
        }
    }
}

//
//  CategoryOption.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-16.
//

import Foundation

enum CategoryOption: String, CaseIterable, Completable {
    
    case noSorting = "No Sorting"
    case dinner = "dinner"
    case salad = "salad"
    case dessert = "dessert"
    case breakfast = "breakfast"
    case soup = "soup"
    case appetizer = "appetizer"
    case beverage = "beverage"
    case timelessClassics = "Timeless Classics"
    case proteinBoost = "Protein Boost"
    case healthy = "Healthy"
    
    var isComplete: Bool {
        switch self {
        case .noSorting:
            return false
        default:
            return true
        }
    }
    
    var description: String? {
        switch self {
        case .noSorting:
            return nil
        case .dinner:
            return "dinner"
        case .salad:
            return "salad"
        case .dessert:
            return "dessert"
        case .breakfast:
            return "breakfast"
        case .soup:
            return "soup"
        case .appetizer:
            return "appetizer"
        case .beverage:
            return "beverage"
        case .timelessClassics:
            return "Timeless Classics"
        case .proteinBoost:
            return "Protein Boost"
        case .healthy:
            return "Healthy"
        }
    }
}

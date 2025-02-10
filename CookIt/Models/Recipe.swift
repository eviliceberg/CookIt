//
//  Recipe.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-06.
//

import Foundation

struct RecipeArray: Codable {
    let recipes: [Recipe]
}

struct Recipe: Codable, Identifiable {
    let id: String
    let title: String
    let isPremium: Bool
    let ingredients: [Ingredient]
    let description: String
    let mainPhoto: String
    let sourceURL: String
    let author: String
    
}

struct Ingredient: Codable {
    let ingredient: String
    let quantity: Int
    let measureMethod: MeasureMethod
}

enum MeasureMethod: String, Codable {
    case grams = "grams"
    case milliliters = "milliliters"
    case pieces = "pieces"
    case teaspoons = "teaspoons"
    case tablespoons = "tablespoons"
    case cups = "cups"
    case pinches = "pinches"
}

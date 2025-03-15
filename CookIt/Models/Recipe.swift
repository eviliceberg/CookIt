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
    let authorId: String?
    let category: [String]
    let statuses: [String]
    let cookingTime: CookingTime
    let steps: [Step]  // Updated: Replaced cookingProcess
    let hint: String?   // Added hint for additional tips
    let nutritionFacts: NutritionFacts // Added nutrition info
    var savedCount: Int  // Added saved count
    var viewCount: Int   // Added view count
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case isPremium = "isPremium"
        case ingredients = "ingredients"
        case description = "description"
        case mainPhoto = "mainPhoto"
        case sourceURL = "sourceURL"
        case author = "author"
        case category = "category"
        case statuses = "statuses"
        case cookingTime = "cookingTime"
        case steps = "steps"
        case hint = "hint"
        case nutritionFacts = "nutritionFacts"
        case savedCount = "savedCount"
        case viewCount = "viewCount"
        case authorId = "authorId"
    }
}

struct Step: Hashable, Codable {
    let stepNumber: Int
    let instruction: String
    let photoURL: String? // Optional image
}

struct NutritionFacts: Codable {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
}

struct CookingTime: Codable {
    let timeNumber: Int
    let timeMeasure: TimeMeasure

    var lowDescription: String {
        switch timeMeasure {
        case .seconds: 
            return "\(timeNumber) sec"
        case .minutes: 
            return "\(timeNumber) min"
        case .hours: 
            return "\(timeNumber) h"
        }
    }
}

enum TimeMeasure: String, Codable, CaseIterable {
    case seconds, minutes, hours
    
    var lowDescription: String {
        switch self {
        case .seconds:
            "sec"
        case .minutes:
            "min"
        case .hours:
            "hr"
        }
    }
}

struct Ingredient: Hashable, Codable {
    var ingredient: String
    var quantity: Float?
    var measureMethod: MeasureMethod?
}

enum MeasureMethod: String, Codable, CaseIterable {
    case grams = "grams"
    case milliliters = "milliliters"
    case pieces = "pieces"
    case pinches = "pinches"
    case slices = "slices"
    case tablespoons = "tablespoons"
    case teaspoons = "teaspoons"
    
    var lowDescription: String {
            switch self {
            case .grams:
                return "g"
            case .milliliters:
                return "ml"
            case .pieces:
                return "pcs"
            case .pinches:
                return "pinch"
            case .slices:
                return "slice"
            case .tablespoons:
                return "tbsp"
            case .teaspoons:
                return "tsp"
            }
        }
}

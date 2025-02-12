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
    //let isFavorite: Bool
    let ingredients: [Ingredient]
    let description: String
    let mainPhoto: String
    let sourceURL: String
    let author: String
    let category: String
    let cookingTime: CookingTime
    let cookingProcess: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case isPremium = "isPremium"
        //case isFavorite = "isFavorite"
        case ingredients = "ingredients"
        case description = "description"
        case mainPhoto = "mainPhoto"
        case sourceURL = "sourceURL"
        case author = "author"
        case category = "category"
        case cookingTime = "cookingTime"
        case cookingProcess = "cookingProcess"
    }
}

enum TimeMeasure: String, Codable {
    case seconds
    case minutes
    case hours
}

struct CookingTime: Codable {
    let timeNumber: Int
    let timeMeasure: TimeMeasure
}


enum RecipeCategory: String, Codable {
    case dinner = "dinner"
    case salad = "salad"
    case dessert = "dessert"
    case breakfast = "breakfast"
    case soup = "soup"
    case appetizer = "appetizer"
    case beverage = "beverage"
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

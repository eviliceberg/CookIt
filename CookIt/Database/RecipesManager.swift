//
//  RecipesManager.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-10.
//

import Foundation
import FirebaseFirestore

final class RecipesManager {
    
    static let shared = RecipesManager()
    private init() { }
    
    private let recipesCollection = Firestore.firestore().collection("recipes")
    
    private func recipeDocument(recipeId: String) -> DocumentReference {
        recipesCollection.document(recipeId)
    }
    
    func uploadRecipes(recipe: Recipe) throws {
        try recipeDocument(recipeId: recipe.id).setData(from: recipe, merge: false)
    }
    
    func getRecipe(by recipeId: String) async throws -> Recipe {
        try await recipeDocument(recipeId: recipeId).getDocument(as: Recipe.self)
    }
    
    func uploadRecipes() async throws {
        do {
            guard let url = Bundle.main.url(forResource: "updated_mock_final", withExtension: "json") else {
                return
            }
            let data = try Data(contentsOf: url)
            
            let result = try JSONDecoder().decode(RecipeArray.self, from: data)
            
            try result.recipes.forEach { try uploadRecipes(recipe: $0) }
            
        } catch {
            print(error)
        }
    }
    
    func getAllRecipes() async throws -> [Recipe] {
        try await recipesCollection.getDocuments(as: Recipe.self)
    }
    
    func updateRecipeFavoriteStatus(isFavorite: Bool, recipeId: String) async throws {
        let data: [String : Any] = [
            Recipe.CodingKeys.isFavorite.rawValue : isFavorite
        ]
        try await recipeDocument(recipeId: recipeId).updateData(data)
    }

//    private func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
//        return try await productsCollection.order(by: Product.CodingKeys.price.rawValue, descending: descending).getDocuments(as: Product.self)
//    }
//
//    private func getAllProductsForCategory(category: String) async throws -> [Product] {
//        return try await productsCollection.whereField(Product.CodingKeys.category.rawValue, isEqualTo: category).getDocuments(as: Product.self)
//    }
//
//    private func getAllProductsByPriceAndCategory(descending: Bool, category: String) async throws -> [Product] {
//        return try await productsCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//            .getDocuments(as: Product.self)
//    }
    
//    private func getAllProductsQuery() -> Query {
//        productsCollection
//    }
//    
//    private func getAllProductsSortedByPriceQuery(descending: Bool) -> Query {
//        return productsCollection.order(by: Product.CodingKeys.price.rawValue, descending: descending)
//    }
//    
//    private func getAllProductsForCategoryQuery(category: String) -> Query {
//        return productsCollection.whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//    }
//    
//    private func getAllProductsByPriceAndCategoryQuery(descending: Bool, category: String) -> Query {
//        return productsCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//    }
//    
//    func getAllProducts(descending: Bool?, category: String?, count: Int, lastDocument: DocumentSnapshot?) async throws -> ([Product], DocumentSnapshot?) {
//        
//        var query: Query = getAllProductsQuery()
//        
//        if let category, let descending {
//            query = getAllProductsByPriceAndCategoryQuery(descending: descending, category: category)
//        } else if let descending {
//            query = getAllProductsSortedByPriceQuery(descending: descending)
//        } else if let category {
//            query = getAllProductsForCategoryQuery(category: category)
//        }
//        
//        return try await query
//            .limit(to: count)
//            .start(afterDocument: lastDocument)
//            .getDocumentsWithSnapShot(as: Product.self)
//    }
//    
//    func getProductsByRating(limit: Int, lastRating: Double?) async throws -> [Product] {
//        try await productsCollection
//            .order(by: Product.CodingKeys.rating.rawValue, descending: true)
//            .limit(to: limit)
//            .start(after: [lastRating ?? 999999])
//            .getDocuments(as: Product.self)
//    }
//    
//    func getProductsByRating(limit: Int, last: DocumentSnapshot?) async throws -> ([Product], DocumentSnapshot?) {
//        if let last {
//            return try await productsCollection
//                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
//                .limit(to: limit)
//                .start(afterDocument: last)
//                .getDocumentsWithSnapShot(as: Product.self)
//        } else {
//            return try await productsCollection
//                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
//                .limit(to: limit)
//                .getDocumentsWithSnapShot(as: Product.self)
//        }
//    }
//    
//    func getAllProductCount() async throws -> Int {
//        return try await productsCollection.aggregateCount()
//    }
    
}


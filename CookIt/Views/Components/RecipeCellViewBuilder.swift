//
//  RecipeCellViewBuilder.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-11.
//

import SwiftUI

struct RecipeCellViewBuilder: View {
    
    let recipeId: String
    @State private var recipe: Recipe? = nil
    
    var body: some View {
        ZStack {
            if let recipe {
                RecipeCellView(
                    title: recipe.title,
                    isPremium: recipe.isPremium,
                    imageURL: recipe.mainPhoto,
                    height: 250
                )
            }
        }
        .task {
            self.recipe = try? await RecipesManager.shared.getRecipe(by: recipeId)
        }
    }
}

#Preview {
    RecipeCellViewBuilder(recipeId: "1")
}

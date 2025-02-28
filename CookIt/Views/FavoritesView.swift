//
//  FavoritesView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-11.
//

import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    
    @Published var favorites: [FavouriteItem] = []
    
    func getFavorites() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        self.favorites = try await UserManager.shared.getFavourites(userId: authUser.uid)
    }
    
    func deleteFavorite(_ recipeId: String) {
        Task {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.removeUserFavouriteRecipe(userId: authUser.uid, favouriteRecipeId: recipeId)
            try await RecipesManager.shared.decrementSavedCount(recipeId: recipeId)
        }
    }
}

struct FavoritesView: View {
    
    @StateObject private var vm = FavoritesViewModel()
    
    var body: some View {
            List {
                ForEach(vm.favorites) { recipe in
                    RecipeCellViewBuilder(recipeId: recipe.productId)
                        .listRowBackground(Color.specialBlack)
                        .listRowSeparator(.hidden)
                        .listRowSpacing(4)
                        .frame(height: 250)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vm.deleteFavorite(recipe.productId)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                }
            }
            .background(.specialBlack)
            .listStyle(.plain)
            .navigationTitle("Favorites")
            .task {
                do {
                    try await vm.getFavorites()
                } catch {
                    print(error)
                }
            }
    }
}

#Preview {
    RootView()
}

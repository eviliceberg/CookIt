//
//  DiscoverView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-10.
//

import SwiftUI
import SwiftfulUI

@MainActor
final class DiscoverViewModel: ObservableObject {
    
    @Published var recipes: [Recipe] = []
    @Published var user: DBUser? = nil
    
    func getRecipes() async throws {
        self.recipes = try await RecipesManager.shared.getAllRecipes()
    }
    
    func loadUser() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authUser.uid)
    }
    
    func addToFavorites(_ recipeId: String) {
        Task {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.addUserFavouriteRecipe(userId: authUser.uid, recipeId: recipeId)
        }
    }
    
}

struct DiscoverView: View {
    
    @StateObject private var vm: DiscoverViewModel = DiscoverViewModel()
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(vm.recipes) { recipe in
                        RecipeCellView(
                            title: recipe.title,
                            isPremium: recipe.isPremium,
                            //imageURL: <#T##String#>,
                            height: 250
                        )
                        .contextMenu {
                            Button {
                                vm.addToFavorites(recipe.id)
                            } label: {
                                HStack {
                                    Text("Add To Favorites")
                                    Image(systemName: "bookmark")
                                        .fontWeight(.bold)
                                }
                            }

                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Discover")
        .onFirstAppear {
            Task {
                do {
                    try await vm.getRecipes()
                    try await vm.loadUser()
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DiscoverView()
    }
}

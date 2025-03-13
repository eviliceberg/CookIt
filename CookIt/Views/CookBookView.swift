//
//  CookBookView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-01.
//

import SwiftUI
import SwiftfulRouting

@MainActor
final class CookBookViewModel: ObservableObject  {
    
    @Published var favorites: [(recipe: Recipe, favouriteId: String)] = []
    
    func getFavorites() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        let favoritesArray = try await UserManager.shared.getFavourites(userId: authUser.uid)
        
        for item in favoritesArray {
            self.favorites.append((try await RecipesManager.shared.getRecipe(by: item.productId), item.id))
        }
    }
    
    func deleteFavorite(_ recipeId: String) {
        Task {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.removeUserFavouriteRecipe(userId: authUser.uid, favouriteRecipeId: recipeId)
            try await RecipesManager.shared.decrementSavedCount(recipeId: recipeId)
        }
    }
    
}

struct CookBookView: View {
    
    @Environment(\.router) var router
    @State private var tabSelected: Bool = true
    
    @StateObject private var vm: CookBookViewModel
    
    init(vm: CookBookViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                    Section {
                        if tabSelected {
                            myRecipesPlaceholder
                        } else {
                            savedSection
                        }
                    } header: {
                        header
                    }
                }
                .animation(.smooth(duration: 0.3), value: tabSelected)
            }
            .scrollIndicators(.hidden)
            .clipped()
            .ignoresSafeArea(edges: .bottom)
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            ReusableHeader(title: "CookBook", router: router)
            
            HStack {
                Text("My recipes")
                    .font(.custom(Constants.appFontBold, size: tabSelected ? 20 : 16))
                    .foregroundStyle(.specialWhite)
                    .opacity(tabSelected ? 1 : 0.6)
                    .onTapGesture {
                        tabSelected = true
                    }
                
                Spacer()
                
                Text("Saved")
                    .font(.custom(Constants.appFontBold, size: tabSelected ? 16 : 20))
                    .foregroundStyle(.specialWhite)
                    .opacity(tabSelected ? 0.6 : 1)
                    .onTapGesture {
                        tabSelected = false
                    }
            }
            .padding(.horizontal, 16)
            
        }
        .padding(.bottom, 4)
        .background(.specialBlack)
    }
    
    private var savedSection: some View {
        ZStack {
            if !vm.favorites.isEmpty {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(vm.favorites, id: \.favouriteId) { favorite in
                        SmallCellView(
                            title: favorite.recipe.title,
                            author: favorite.recipe.author,
                            time: favorite.recipe.cookingTime.lowDescription,
                            photoUrl: favorite.recipe.mainPhoto,
                            status: favorite.recipe.statuses.first ?? "",
                            isPremium: favorite.recipe.isPremium,
                            height: 184,
                            width: 173
                        )
                    }
                }
            } else {
                VStack {
                    Text("Your saved recipes will appear here!")
                        .font(.custom(Constants.appFontBold, size: 18))
                        .foregroundStyle(.specialLightGray)
                    Text("Explore new flavors and save your favorite recipe for easy access later.")
                        .font(.custom(Constants.appFontMedium, size: 16))
                        .foregroundStyle(.specialWhite)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 64)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var myRecipesPlaceholder: some View {
        VStack {
            Text("You haven't saved any recipes yet")
                .font(.custom(Constants.appFontBold, size: 18))
                .foregroundStyle(.specialLightGray)
            Text("Create your own delicious recipes and save them here – tap the button below!")
                .font(.custom(Constants.appFontMedium, size: 16))
                .foregroundStyle(.specialWhite)
                .multilineTextAlignment(.center)
            Circle()
                .fill(.specialGreen)
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "plus")
                        .font(.title)
                        .fontWeight(.bold)
                        .imageScale(.large)
                        .foregroundStyle(.specialBlack)
                }
                .onTapGesture {
                    
                }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 64)
        .padding(.horizontal, 16)
    }
    
}

#Preview {
    RootView()
}

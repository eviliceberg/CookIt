//
//  HomeView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-15.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulRouting
import SwiftfulUI

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var authUser: DBUser? = nil
    @Published var recipes: [Recipe] = []
    @Published var onePanRecipes: [Recipe] = []
    @Published var proteinBoostRecipes: [Recipe] = []
    @Published var timelessClassicRecipes: [Recipe] = []
    
    @State private var isFetching: Bool = false
    
    func fetchAllData() async throws {
        async let popularRecipes = getRecipes(popular: true)
        async let onePanRecipes = getRecipes(category: CategoryOption.breakfast.description)
        async let timelessClassicRecipes = getRecipes(category: CategoryOption.timelessClassics.description)
        async let proteinBoostRecipes = getRecipes(category: CategoryOption.proteinBoost.description)
        
        
        recipes = await popularRecipes
        self.onePanRecipes = await onePanRecipes
        self.timelessClassicRecipes = await timelessClassicRecipes
        self.proteinBoostRecipes = await proteinBoostRecipes
    }
    
    func savePath(path: String) -> URL {
        return FileManager.documentsDirectory.appending(path: path)
    }
    
    func saveRecipesArray(array: [Recipe], path: String) throws {
        let data = try JSONEncoder().encode(array)
        
        let pathURL = savePath(path: path)
        
        try data.write(to: pathURL)
    }
    
    func loadCurrentUser() async throws {
        let tempUser = try AuthenticationManager.shared.getAuthenticatedUser()
        self.authUser = try await UserManager.shared.getUser(userId: tempUser.uid)
    }
    
    func addToFavorites(_ recipeId: String) {
        Task {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.addUserFavouriteRecipe(userId: authUser.uid, recipeId: recipeId)
            try await RecipesManager.shared.incrementSavedCount(recipeId: recipeId)
        }
    }
    
    func getRecipes(category: String? = nil, popular: Bool? = nil, recipesArray: [Recipe]? = nil) async -> [Recipe] {
        guard !isFetching else { return [] }
        isFetching = true
        var resultArray: [Recipe] = []
        do {
            let (newRecipes, _) = try await RecipesManager.shared.getAllRecipes(descending: nil, category: category, popular: popular, count: 10, lastDocument: nil)
            
            if let recipesArray {
                resultArray.append(contentsOf: recipesArray)
            }
            resultArray.append(contentsOf: newRecipes)
            
        } catch {
            print(error)
            return []
        }
        isFetching = false
        if popular == true {
            return resultArray
        }
        return resultArray.shuffled()
    }
    
}

struct HomeView: View {
    
    @Environment(\.router) var router
    @Binding var showWelcomeView: Bool

    @EnvironmentObject var vm: HomeViewModel
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                    Section {
                        
                        wideCellSection(title: "Most Popular", recipes: vm.recipes)
                        
                        smallCellSection(title: "One-Pan Magic", recipes: vm.onePanRecipes)
                        
                        if let recipe = vm.recipes.last {
                            PremiumCellView(
                                imageUrl: recipe.mainPhoto,
                                author: recipe.author,
                                title: recipe.title,
                                time: recipe.cookingTime.lowDescription
                            )
                            .padding(.horizontal, 16)
                            .onTapGesture {
                                
                            }
                        }
                        
                        MysteryToolCell()
                            .padding(.horizontal, 16)
                            .onTapGesture {
                                
                            }
                        
                        smallCellSection(title: CategoryOption.proteinBoost.rawValue, recipes: vm.proteinBoostRecipes)
                        
                        wideCellSection(title: CategoryOption.timelessClassics.rawValue, recipes: vm.timelessClassicRecipes)
                    } header: {
                        header
                    }

                }
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .clipped()
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .fill(.specialBlack)
                .frame(width: 60, height: 60)
                .overlay {
                    Image(.cookbook)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                }
                .padding(.trailing, 24)
                .onTapGesture {
                    router.showScreen(.push) { _ in
                        CookBookView()
                    }
                }
        }
        .onAppear {
            Task {
                do {
                    
                try await vm.loadCurrentUser()
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            HStack(spacing: 16) {
                if let imageURL = vm.authUser?.photoUrl {
                    ImageLoaderView(urlString: imageURL)
                        .frame(width: 40, height: 40)
                        .clipShape(.circle)
                        .onTapGesture {
                            guard let authUser = vm.authUser else {
                                return
                            }
                            router.showScreen(.push) { _ in
                                ProfileView(user: authUser, showWelcomeScreen: $showWelcomeView)
                            }
                        }
                } else {
                    Image(.user)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(.circle)
                        .onTapGesture {
                            guard let authUser = vm.authUser else {
                                return
                            }
                            router.showScreen(.push) { _ in
                                ProfileView(user: authUser, showWelcomeScreen: $showWelcomeView)
                            }
                        }
                }
                if let user = vm.authUser {
                    Text("Hello, \(user.name ?? "User")")
                } else {
                    Text("Hello, User")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "magnifyingglass")
                .fontWeight(.semibold)
                .frame(width: 24, height: 24)
                .padding(4)
                .offset(x: 4)
                .background(.specialBlack.opacity(0.00001))
                .asButton(.tap) {
                    
                }
        }
        .font(.custom(Constants.appFontSemiBold, size: 20))
        .foregroundStyle(.specialWhite)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .background(.specialBlack)
    }
    
    private func wideCellSection(title: String, recipes: [Recipe]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom(Constants.appFontBold, size: 24))
                .foregroundStyle(.specialWhite)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(recipes) { recipe in
                        MostPopularCellView(
                            statuses: recipe.statuses,
                            cookingTime: recipe.cookingTime.lowDescription,
                            author: recipe.author,
                            title: recipe.title,
                            imageURL: recipe.mainPhoto
                        )
                        .asButton(.tap) {
                            router.showScreen(.push) { _ in
                                RecipeView(recipe: recipe)
                            }
                        }
                        .contextMenu {
                            Button {
                                vm.addToFavorites(recipe.id)
                            } label: {
                                Text("Add to favorites")
                            }

                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private func smallCellSection(title: String, recipes: [Recipe]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom(Constants.appFontBold, size: 24))
                .foregroundStyle(.specialWhite)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(recipes) { recipe in
                        SmallCellView(
                            title: recipe.title,
                            author: recipe.author,
                            time: recipe.cookingTime.lowDescription,
                            photoUrl: recipe.mainPhoto,
                            status: recipe.statuses.first ?? "",
                            isPremium: recipe.isPremium
                        )
                        .asButton(.tap) {
                            router.showScreen(.push) { _ in
                                RecipeView(recipe: recipe)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
        }
    }
    
}

#Preview {
    RouterView { _ in
        RootView()
    }
}

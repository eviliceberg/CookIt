//
//  DiscoverView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-10.
//

import SwiftUI
import SwiftfulUI
import FirebaseFirestore

@MainActor
final class DiscoverViewModel: ObservableObject {
    
    @Published var recipes: [Recipe] = []
    @Published var user: DBUser? = nil
    
    @Published var categoryOption: CategoryOption = .noSorting {
        didSet {
            Task {
                await self.categorySelected()
            }
        }
    }
    
    private var lastDocument: DocumentSnapshot? = nil
    @State private var isFetching: Bool = false
    
    enum CategoryOption: String, CaseIterable {
        case noSorting = "No Sorting"
        case dinner = "dinner"
        case salad = "salad"
        case dessert = "dessert"
        case breakfast = "breakfast"
        case soup = "soup"
        case appetizer = "appetizer"
        case beverage = "beverage"
        
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
            }
        }
    }
    
    func categorySelected() async {
        self.recipes = []
        self.lastDocument = nil
        await self.getRecipes()
    }
    
    func getRecipes() async {
        guard !isFetching else { return }
        isFetching = true
        do {
            let (newRecipes, newLastDocument) = try await RecipesManager.shared.getAllRecipes(descending: nil, category: categoryOption.description, count: 5, lastDocument: lastDocument)
            
            if let newLastDocument {
                self.lastDocument = newLastDocument
            }
            recipes.append(contentsOf: newRecipes)
        } catch {
            print(error)
        }
        isFetching = false
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
                        if recipe.id == vm.recipes.last?.id {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .onAppear {
                                Task {
                                    await vm.getRecipes()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Picker("Sorting", selection: $vm.categoryOption) {
                        ForEach(DiscoverViewModel.CategoryOption.allCases, id: \.self) { option in
                            Text(option.rawValue.capitalized).tag(option)
                        }
                    }
                } label: {
                    Label("Sorting", systemImage: "line.3.horizontal.decrease")
                }
            }
        })
        .preferredColorScheme(.dark)
        .navigationTitle("Discover")
        .onFirstAppear {
            Task {
                do {
                    await vm.getRecipes()
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

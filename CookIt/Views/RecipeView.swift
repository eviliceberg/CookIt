//
//  RecipeView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-21.
//

import SwiftUI
import SwiftfulUI

@MainActor
final class RecipesViewModel: ObservableObject {
    @Published var recipe: Recipe
    @Published var author: DBUser?
    
    init(recipe: Recipe, author: DBUser? = nil) {
        self.recipe = recipe
        self.author = author
    }
}

struct RecipeView: View {
    
    @StateObject private var vm: RecipesViewModel
    
    init(recipe: Recipe, author: DBUser? = nil) {
        _vm = StateObject(wrappedValue: RecipesViewModel(recipe: recipe, author: author))
    }
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                    Section {
                        
                        RecipePhotoCell(
                            photoURL: vm.recipe.mainPhoto,
                            statuses: vm.recipe.statuses,
                            isPremium: vm.recipe.isPremium,
                            category: vm.recipe.category.first ?? "",
                            cookingTime: vm.recipe.cookingTime.lowDescription
                        )
                        .padding(.horizontal, 12)
                        
                        authorSection
                            .padding(.horizontal, 12)
                        
                        ForEach(0..<10) { _ in
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 150)
                        }
                    } header: {
                        header
                    }
                }
            }
            .scrollIndicators(.hidden)
            .clipped()
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    private var header: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "chevron.left")
                .font(.custom(Constants.appFontSemiBold, size: 24))
                .asButton(.press) {
                    
                }
            
            Text(vm.recipe.title)
                .font(.custom(Constants.appFontSemiBold, size: 24))
                .frame(maxWidth: .infinity, alignment: .center)
            
        }
        .foregroundStyle(.specialWhite)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .background(.specialBlack)
    }
    
    private var authorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack {
                    if let authorPhoto = vm.author?.photoUrl {
                        ImageLoaderView(urlString: authorPhoto)
                            .frame(width: 40, height: 40)
                            .clipShape(.circle)
                    } else {
                        Image(.user)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(.circle)
                    }
                    
                    VStack {
                        Text(vm.recipe.author)
                            .font(.custom(Constants.appFont, size: 12))
                        
                        if let author = vm.author {
                            Text("chef")
                                .font(.custom(Constants.appFontMedium, size: 10))
                                .foregroundStyle(.specialBlack)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background()
                        }
                    }
                }
                Group {
                    if vm.recipe.savedCount == 1 {
                        Text("\(vm.recipe.savedCount) person saved this recipe")
                    } else if vm.recipe.savedCount == 0 {
                        Text("")
                    } else {
                        Text("\(vm.recipe.savedCount) people saved this recipe")
                    }
                }
                .font(.custom(Constants.appFont, size: 12))
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Text(vm.recipe.description)
                .font(.custom(Constants.appFont, size: 14))
        }
        .foregroundStyle(.specialWhite)
    }
    
}

fileprivate struct RecipesViewPreview: View {
    
    @State private var recipe: Recipe? = nil
    
    var body: some View {
        ZStack {
            if let recipe {
                RecipeView(recipe: recipe)
            }
        }
        .task {
            recipe = try? await RecipesManager.shared.getRecipe(by: "1")
        }
    }
}

#Preview {
    RecipesViewPreview()
}

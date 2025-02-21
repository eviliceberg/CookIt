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
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
}

struct RecipeView: View {
    
    @StateObject private var vm: RecipesViewModel
    
    init(recipe: Recipe) {
        _vm = StateObject(wrappedValue: RecipesViewModel(recipe: recipe))
    }
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                    Section {
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

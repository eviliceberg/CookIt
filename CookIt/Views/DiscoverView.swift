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
    
    func getRecipes() async throws {
        self.recipes = try await RecipesManager.shared.getAllRecipes()
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
                    //        imageURL: <#T##String#>,
                            height: 250
                        )
                        .onTapGesture {
                           
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .navigationTitle("Discover")
        .onFirstAppear {
            Task {
                do {
                    try await vm.getRecipes()
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

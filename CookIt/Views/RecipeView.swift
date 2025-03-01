//
//  RecipeView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-21.
//

import SwiftUI
import SwiftfulUI
import SwiftfulRouting

@MainActor
final class RecipesViewModel: ObservableObject {
    @Published var recipe: Recipe
    @Published var author: DBUser?
    @Published var servingNumber: Int = 1
    
    @Published var similarRecipes: [Recipe]? = nil
    
    init(recipe: Recipe, author: DBUser? = nil) {
        self.recipe = recipe
        self.author = author
    }
    
    func addServingNumber() {
        guard self.servingNumber < 15 else { return }
        self.servingNumber += 1
    }
    
    func takeServingNumber() {
        guard self.servingNumber > 1 else { return }
        self.servingNumber -= 1
    }
    
    func incrementViews() async {
        do {
            try await RecipesManager.shared.incrementViewCount(recipeId: recipe.id)
        } catch {
            print(error)
        }
    }
    
    func getRecipes(category: String? = nil, recipesArray: [Recipe]? = nil) async -> [Recipe] {
        var resultArray: [Recipe] = []
        do {
            let (newRecipes, _) = try await RecipesManager.shared.getAllRecipes(descending: nil, category: category, popular: nil, count: 10, lastDocument: nil)
            
            if let recipesArray {
                resultArray.append(contentsOf: recipesArray)
            }
            resultArray.append(contentsOf: newRecipes)
            
        } catch {
            print(error)
            return []
        }
        return resultArray.shuffled()
    }
    
}

struct RecipeView: View {
    
    @StateObject private var vm: RecipesViewModel
    
    @Environment(\.router) var router
    
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
                            
                        ingredientsSection
                        
                        nutritionSection
                        
                        stepsSection
                        
                        if let hint = vm.recipe.hint {
                            hintSection(hint)
                        }
                        
                        similarRecipesSection
                        
                    } header: {
                        header
                    }
                }
            }
            .scrollIndicators(.hidden)
            .clipped()
            .ignoresSafeArea(edges: .bottom)
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .task {
            await vm.incrementViews()
        }
        .onFirstAppear {
            Task {
                vm.similarRecipes = await vm.getRecipes()
                vm.similarRecipes?.removeAll(where: { $0.id == vm.recipe.id })
            }
        }
    }
    
    private var header: some View {
        ReusableHeader(title: vm.recipe.title, router: router)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
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
        .padding(.horizontal, 12)
        .foregroundStyle(.specialWhite)
    }
    
    private var ingredientsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Ingredients")
                    .font(.custom(Constants.appFontBold, size: 20))
                
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.specialLightBlack)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "minus")
                                .foregroundStyle(.specialGreen)
                                .fontWeight(.semibold)
                        }
                        .asButton(.press) {
                            vm.takeServingNumber()
                        }
                    
                    Text("\(vm.servingNumber) serving")
                        .font(.custom(Constants.appFontSemiBold, size: 16))
                    
                    Circle()
                        .fill(Color.specialLightBlack)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "plus")
                                .foregroundStyle(.specialGreen)
                                .fontWeight(.semibold)
                        }
                        .asButton(.press) {
                            vm.addServingNumber()
                        }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            VStack {
                ForEach(vm.recipe.ingredients, id: \.self) { ingredient in
                    HStack {
                        Group {
                            Text("\(ingredient.quantity * vm.servingNumber) ")
                                .font(.custom(Constants.appFontBold, size: 16))
                            +
                            Text(ingredient.measureMethod.rawValue)
                                .font(.custom(Constants.appFont, size: 16))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(ingredient.ingredient.capitalized)
                            .font(.custom(Constants.appFont, size: 16))
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .foregroundStyle(.specialWhite)
    }
    
    private var nutritionSection: some View {
        VStack(alignment: .leading) {
            Text("Nutrition facts")
                .font(.custom(Constants.appFontBold, size: 20))
            
            HStack {
                Group {
                    Text("Cal")
                        .font(.custom(Constants.appFont, size: 16))
                    +
                    Text(" \(vm.recipe.nutritionFacts.calories.description)")
                        .font(.custom(Constants.appFontSemiBold, size: 16))
                }
                Spacer()
                Group {
                    Text("Prot")
                        .font(.custom(Constants.appFont, size: 16))
                    +
                    Text(" \(vm.recipe.nutritionFacts.protein.description)g")
                        .font(.custom(Constants.appFontSemiBold, size: 16))
                }
                Spacer()
                Group {
                    Text("Carb")
                        .font(.custom(Constants.appFont, size: 16))
                    +
                    Text(" \(vm.recipe.nutritionFacts.carbs.description)g")
                        .font(.custom(Constants.appFontSemiBold, size: 16))
                }
                Spacer()
                Group {
                    Text("Fat")
                        .font(.custom(Constants.appFont, size: 16))
                    +
                    Text(" \(vm.recipe.nutritionFacts.fat.description)g")
                        .font(.custom(Constants.appFontSemiBold, size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .foregroundStyle(.specialWhite)
    }
    
    private var stepsSection: some View {
        VStack(alignment: .leading) {
            Text("Instructions")
                .font(.custom(Constants.appFontBold, size: 20))
            ForEach(vm.recipe.steps, id: \.self) { step in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Step \(step.stepNumber)")
                        .font(.custom(Constants.appFontSemiBold, size: 16))
                    Text(step.instruction)
                        .font(.custom(Constants.appFont, size: 16))
                    
                    if let photo = step.photoURL {
                        ImageLoaderView(urlString: photo)
                            .frame(height: 140)
                            .clipShape(.rect(cornerRadius: 20))
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .padding(.horizontal, 12)
        .foregroundStyle(.specialWhite)
    }
    
    private func hintSection(_ hint: String) -> some View {
        VStack(alignment: .leading) {
            Text("Helpful Hints")
                .font(.custom(Constants.appFontBold, size: 20))
            
            HStack {
                Image(systemName: "star.fill")
                    .imageScale(.small)
                
                Text(hint)
                    .font(.custom(Constants.appFont, size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .foregroundStyle(.specialWhite)
        .padding(.horizontal, 12)
    }
    
    private var similarRecipesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Similar Recipes")
                .font(.custom(Constants.appFontBold, size: 20))
                .padding(.horizontal, 12)
            
            ScrollView(.horizontal) {
                LazyHStack {
                    if let similarRecipes = vm.similarRecipes {
                        ForEach(similarRecipes) { recipe in
                            SmallCellView(
                                title: recipe.title,
                                author: recipe.author,
                                time: recipe.cookingTime.lowDescription,
                                photoUrl: recipe.mainPhoto,
                                status: recipe.statuses.first ?? "",
                                isPremium: recipe.isPremium
                            )
                            .onTapGesture {
                                router.showScreen(.push) { _ in
                                    RecipeView(recipe: recipe)
                                }
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
                .padding(.horizontal, 12)
            }
            
        }
        .foregroundStyle(.specialWhite)
        .padding(.bottom, 32)
    }
    
}

fileprivate struct RecipesViewPreview: View {
    
    @State private var recipe: Recipe? = nil
    
    var body: some View {
        ZStack {
            if let recipe {
                RouterView { _ in
                    RecipeView(recipe: recipe)
                }
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

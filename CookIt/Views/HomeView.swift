//
//  HomeView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-15.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var authUser: DBUser? = nil
    @Published var recipes: [Recipe] = []
    
    @State private var isFetching: Bool = false
    
    func loadCurrentUser() async throws {
        let tempUser = try AuthenticationManager.shared.getAuthenticatedUser()
        self.authUser = try await UserManager.shared.getUser(userId: tempUser.uid)
    }
    
    func getRecipes() async {
        guard !isFetching else { return }
        isFetching = true
        do {
            let (newRecipes, _) = try await RecipesManager.shared.getAllRecipes(descending: nil, category: nil, count: 10, lastDocument: nil)
            
            self.recipes.append(contentsOf: newRecipes)
        } catch {
            print(error)
        }
        isFetching = false
    }
    
}

struct HomeView: View {
    
    @StateObject private var vm: HomeViewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: .sectionHeaders) {
                    Section {
                        
                        mostPopularSection
                        
                        ForEach(0..<10) { _ in
                            Rectangle()
                                .fill(Color.blue)
                                .frame(height: 175)
                        }
                    } header: {
                        header
                    }

                }
            }
            .scrollIndicators(.hidden)
            .clipped()
        }
//        .task {
//            try? await RecipesManager.shared.uploadRecipes()
//        }
        .onAppear {
            if vm.recipes.isEmpty {
                Task {
                    do {
                        try await vm.loadCurrentUser()
                        await vm.getRecipes()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            HStack(spacing: 16) {
                ImageLoaderView()
                    .frame(width: 40, height: 40)
                    .clipShape(.circle)
                
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
    
    private var mostPopularSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Most Popular")
                .font(.custom(Constants.appFontBold, size: 24))
                .foregroundStyle(.specialWhite)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(vm.recipes) { recipe in
                        MostPopularCellView(
                            statuses: recipe.statuses,
                            cookingTime: recipe.cookingTime.lowDescription,
                            author: recipe.author,
                            title: recipe.title
                            //imageURL: <#T##String#>
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
        }
    }
    
}

#Preview {
    RootView()
}

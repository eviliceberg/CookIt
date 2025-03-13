//
//  AddNewRecipeView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-13.
//

import SwiftUI
import SwiftfulRouting

@MainActor
final class AddNewRecipeViewModel: ObservableObject {
    
    @Published var stepsDone: Int = 5
    
    @Published var titleText: String = ""
    @Published var descriptionText: String = ""
    @Published var typeSelection: CategoryOption = .noSorting
    @Published var timeText: String = ""
    
}

struct AddNewRecipeView: View {
    
    @Environment(\.router) var router
    
    @StateObject private var vm: AddNewRecipeViewModel = AddNewRecipeViewModel()
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 8, pinnedViews: .sectionHeaders) {
                    Section {
                        
                        StrokedTextfield(systemName: .pen, placeholder: "Dish Title", text: $vm.titleText, lineLimit: 1)
                        
                        ForEach(0..<7) { index in
                            if index == 1 {
                                Button("Add to progress") {
                                    guard vm.stepsDone <= 8 else { return }
                                    vm.stepsDone += 1
                                }
                            } else {
                                Rectangle()
                                    .fill(Color.specialPink)
                                    .frame(height: 150)
                            }
                        }
                    } header: {
                        header
                    }
                }
            }
            .scrollIndicators(.hidden)
            .clipped()
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
    
    private var header: some View {
        ZStack(alignment: .center) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.custom(Constants.appFontSemiBold, size: 24))
                    .asButton(.press) {
                        router.dismissScreen()
                    }
                
                Text("\(vm.stepsDone)/8")
                    .font(.custom(Constants.appFontMedium, size: 20))
                    .foregroundStyle(vm.stepsDone >= 8 ? .specialWhite : .specialDarkGrey)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(
                            LinearGradient(colors: [.specialGreen, .specialYellow, .specialPink, .specialLightPurple, .specialLightBlue], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.specialLightBlack)
                        .frame(width: geo.size.width / 8  * (8 - CGFloat(vm.stepsDone)))
                    
                }
                .animation(.easeInOut, value: vm.stepsDone)
            }
            .frame(height: 6)
            .padding(.horizontal, 48)
            
        }
        .padding(.horizontal, 16)
        .foregroundStyle(.specialWhite)
        .background(.specialBlack)
    }
    
}

#Preview {
    AddNewRecipeView()
}

//
//  AddNewRecipeView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-13.
//

import SwiftUI
import SwiftfulRouting
import PhotosUI

struct Steps {
    var text: String = ""
    var image: PhotosPickerItem? = nil
    
    var imageUI: UIImage? {
        get async {
            do {
                guard let data = try await image?.loadTransferable(type: Data.self) else { throw CookItErrors.noData }
                return UIImage(data: data)
            } catch {
                print(CookItErrors.noData)
            }
            return nil
        }
    }
}


@MainActor
final class AddNewRecipeViewModel: ObservableObject {
    
    @Published var stepsDone: Int = 5
    
    @Published var titleText: String = ""
    @Published var descriptionText: String = ""
    @Published var typeSelection: CategoryOption = .noSorting
    @Published var timeText: String = ""
    @Published var timeMeasure: TimeMeasure = .minutes
    
    @Published var ingredients: [Ingredient] = [Ingredient(ingredient: "", quantity: nil, measureMethod: nil)]
    
    
    @Published var mainPhoto: PhotosPickerItem? = nil {
        didSet {
            Task {
                do {
                    guard let safePhoto = mainPhoto else { return }
                    self.mainPhotoUI = try await convertToUIImage(image: safePhoto)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @Published var mainPhotoUI: UIImage? = nil
    
    func convertToUIImage(image: PhotosPickerItem) async throws -> UIImage? {
        guard let data = try await image.loadTransferable(type: Data.self) else {
            throw CookItErrors.noData
        }
        
        return UIImage(data: data)
    }
    
}

struct AddNewRecipeView: View {
    
    @Environment(\.router) var router
    
    @StateObject private var vm: AddNewRecipeViewModel = AddNewRecipeViewModel()
    
    @FocusState private var state: Bool 

    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: .sectionHeaders) {
                    Section {
                        StrokedTextfield(systemName: .pen, placeholder: "Dish Title", text: $vm.titleText, focus: $state)
                            .padding(.horizontal, 16)
                        
                        photoPickerCell(photo: $vm.mainPhoto, photoUI: vm.mainPhotoUI)
                        
                        typeAndTimeSection
                        
                        StrokedTextfield(systemName: .pen, placeholder: "Description", text: $vm.descriptionText, focus: $state)
                            .padding(.horizontal, 16)
                        
                        ingredientsSection
                        
                    } header: {
                        header
                    }
                }
            }
            .scrollIndicators(.hidden)
            .clipped()
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .onTapGesture {
            state = false
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
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
    
    private func photoPickerCell(photo: Binding<PhotosPickerItem?>, photoUI: UIImage?) -> some View {
        ZStack {
            if let thumbnail = photoUI {
                PhotosPicker(selection: photo, photoLibrary: .shared()) {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(.rect(cornerRadius: 20))
                }
            } else {
                PhotosPicker(selection: photo, photoLibrary: .shared()) {
                    PhotoPickerLabel()
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var typeAndTimeSection: some View {
        HStack(spacing: 16) {
                Menu {
                    Picker("Type", selection: $vm.typeSelection) {
                        ForEach(CategoryOption.allCases, id: \.self) { option in
                            Text(option == .noSorting ? "Type" : option.rawValue.capitalized)
                                .tag(option)
                        }
                    }
                } label: {
                    HStack {
                        Text(vm.typeSelection == .noSorting ? "Type" : vm.typeSelection.rawValue.capitalized)
                            .font(.custom(Constants.appFontMedium, size: 16))
                            .foregroundStyle(.specialLightGray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(y: 1)
                        
                        Image(.food)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundStyle(.specialDarkGrey)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.specialDarkGrey)
                    )
                }
            
            HStack {
                SuperTextField(textFieldType: .regular, placeholder: Text("Time")
                    .foregroundStyle(.specialLightGray)
                    .font(.custom(Constants.appFontMedium, size: 16)), text: $vm.timeText, lineLimit: 1, focusState: $state)
                .offset(y: 1)
                
                
                Menu {
                    Picker("Select Time", selection: $vm.timeMeasure) {
                        ForEach(TimeMeasure.allCases, id: \.self) { option in
                            Text(option.lowDescription)
                                .tag(option)
                        }
                    }
                } label: {
                    HStack {
                        Text(vm.timeMeasure.lowDescription)
                            .foregroundStyle(.specialLightGray)
                            .font(.custom(Constants.appFontMedium, size: 16))
                            .offset(y: 1)
                        
                        Image(.clock)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundStyle(.specialDarkGrey)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.specialDarkGrey)
            )
        }
        .padding(.horizontal, 16)
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Ingredients")
                .font(.custom(Constants.appFontBold, size: 20))
                .foregroundStyle(!vm.ingredients[0].ingredient.isEmpty ? .specialWhite : .specialLightGray)
            VStack(spacing: 8) {
                ForEach(vm.ingredients.indices, id: \.self) { index in
                    HStack {
                        StrokedTextfield(systemName: .pen, placeholder: "Name", text: $vm.ingredients[index].ingredient, focus: $state)
                        
                        HStack {
                            SuperTextField(textFieldType: .keypad, placeholder: Text("Quantity") .foregroundStyle(.specialLightGray)
                                .font(.custom(Constants.appFontMedium, size: 16)), text:
                                            Binding(
                                                get: {
                                                    if let quantity = vm.ingredients[index].quantity {
                                                        String(format: "%.2f", quantity)
                                                    } else {
                                                        ""
                                                    }
                                                },
                                                set: { newValue in
                                                    vm.ingredients[index].quantity = Float(newValue)
                                                }
                                            ), lineLimit: 1, focusState: $state)
                            .offset(y: 1)
                            
                            Menu {
                                Picker("", selection: $vm.ingredients[index].measureMethod) {
                                    ForEach(MeasureMethod.allCases, id: \.rawValue) { measureMethod in
                                        Text(measureMethod.rawValue)
                                            .tag(measureMethod)
                                    }
                                }
                            } label: {
                                if let measure = vm.ingredients[index].measureMethod {
                                    Text(measure.lowDescription)
                                        .foregroundStyle(.specialWhite)
                                        .font(.custom(Constants.appFontSemiBold, size: 16))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                } else {
                                    Image(.weight)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 24)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(.specialLightBlack)
                                        .clipShape(.rect(cornerRadius: 20))
                                }
                            }
                        }
                        .padding(.leading, 18)
                        .padding(.trailing, 8)
                        .padding(.vertical, 8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.specialDarkGrey)
                        }
                        .animation(.bouncy, value: vm.ingredients[index].measureMethod)
                    }
                }
            }
        }
        .onChange(of: vm.ingredients.last, { oldValue, newValue in
            withAnimation {
                if let last = vm.ingredients.last {
                    if !last.ingredient.isEmpty {
                        vm.ingredients.append(Ingredient(ingredient: "", quantity: nil, measureMethod: nil))
                    }
                }
            }
        })
        .padding(.horizontal, 16)
    }
    
}

#Preview {
    AddNewRecipeView()
}

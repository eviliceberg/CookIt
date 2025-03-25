//
//  AddNewRecipeView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-13.
//

import SwiftUI
import SwiftfulRouting
import PhotosUI
import Combine

protocol Completable {
    var isComplete: Bool { get }
}

@MainActor
final class AddNewRecipeViewModel: ObservableObject {
    
    var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    var stepsDone: Int {
        let fields = [titleText, descriptionText, timeText, hint]
        let typeFields: [Completable] = [typeSelection, ingredients[0], steps[0]]
        let typeFieldsCount = typeFields.filter { $0.isComplete }.count
        let fieldCount = fields.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
        return mainPhotoUI != nil ? (fieldCount + typeFieldsCount + 1) : fieldCount + typeFieldsCount
    }
    
    @Published var titleText: String = ""
    @Published var descriptionText: String = ""
    @Published var typeSelection: CategoryOption = .noSorting
    @Published var timeText: String = ""
    @Published var timeMeasure: TimeMeasure = .minutes
    
    @Published var ingredients: [Ingredient] = [Ingredient(ingredient: "", quantity: nil, measureMethod: nil)]
    
    @Published var steps: [Step] = [Step(stepNumber: 1, instruction: "", photoURL: nil)]
    @Published var stepImages: [PhotosPickerItem?] = [nil]
    @Published var stepUIImages: [UIImage?] = [nil]
    
    
    @Published var mainPhoto: PhotosPickerItem? = nil
    
    @Published var mainPhotoUI: UIImage? = nil
    @Published var hint: String = ""
    
    var doneButtonOpacity: Double = 0
    
    init() {
        showDoneButton()
        updateUIImage()
        updateIngredientsSection()
        updateSteps()
    }
    
    func updateIngredientsSection() {
        $ingredients
            .receive(on: DispatchQueue.main)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] ingredientArr in
                guard let last = ingredientArr.last, !last.ingredient.isEmpty else { return }
                guard let self = self else { return }

                withAnimation {
                    self.ingredients.append(Ingredient(ingredient: "", quantity: nil, measureMethod: nil))
                }
            }
            .store(in: &cancellables)
    }
    
    func updateUIImage() {
        $mainPhoto
            .sink { [weak self] item in
                guard let item = item else { return }
                Task {
                    do {
                        self?.mainPhotoUI = try await self?.convertToUIImage(image: item)
                    } catch {
                        print(error)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func updateSteps() {
        $steps
            .receive(on: DispatchQueue.main)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] stepsArr in
                guard let last = stepsArr.last, !last.instruction.isEmpty else { return }
                guard let self = self else { return }

                withAnimation {
                    self.steps.append(Step(stepNumber: last.stepNumber + 1, instruction: "", photoURL: nil))
                    self.stepImages.append(nil)
                    self.stepUIImages.append(nil)
                }
            }
            .store(in: &cancellables)
    }
    
    func showDoneButton() {
        
        let firstCombination = Publishers.CombineLatest3($descriptionText, $typeSelection, $timeText)
        
        let secondCombination = Publishers.CombineLatest4($ingredients, $steps, $mainPhotoUI, $hint)
        
        $titleText
            .combineLatest(firstCombination, secondCombination)
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink { [weak self] (text, first, second) in
                guard let firstIngredient = second.0.first else { return }
                
                let lastStep = second.1[second.1.count >= 3 ? second.1.count - 2 : second.1.count - 1]
                
                if text.count > 3 &&
                    first.0.count > 3 &&
                    first.1 != .noSorting &&
                    first.2 != "" &&
                    (!firstIngredient.ingredient.isEmpty && firstIngredient.measureMethod != nil && firstIngredient.quantity != nil) &&
                    (lastStep.stepNumber >= 2 && !lastStep.instruction.isEmpty) &&
                    second.2 != nil &&
                    !second.3.isEmpty {
                    self?.doneButtonOpacity = 1
                } else {
                    self?.doneButtonOpacity = 0
                }
            }
            .store(in: &cancellables)
        
    }
    
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
    
    @StateObject private var keyboardManager = KeyboardResponder()

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
                        
                        stepsSection
                        
                        hintSection
                        
                        Spacer(minLength: keyboardManager.currentHeight == 0 ? 48 : keyboardManager.currentHeight + 16)
                        
                    } header: {
                        header
                    }
                }
            }
            .scrollIndicators(.hidden)
            .clipped()
            .ignoresSafeArea(.all, edges: .bottom)
            //.scrollPosition(id: $vm.scrollTo)
        }
        .overlay {
            VStack {
                Spacer()
                
                Text("Done!")
                    .foregroundStyle(.specialBlack)
                    .font(.custom(Constants.appFontBold, size: 24))
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(.specialGreen)
                    .clipShape(.rect(cornerRadius: 30))
                    .padding(.horizontal, 16)
                    .opacity(vm.doneButtonOpacity)
                    .allowsHitTesting(vm.doneButtonOpacity == 1 ? true : false)
                    .asButton(.press) {
                       
                    }
            }
            .animation(.linear, value: vm.doneButtonOpacity)
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
                        .fill(Color.specialLightBlack)
                        .frame(width: geo.size.width)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(
                            LinearGradient(colors: [.specialGreen, .specialYellow, .specialPink, .specialLightPurple, .specialLightBlue], startPoint: .leading, endPoint: .trailing)
                        )
                        .mask(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.specialLightBlack)
                                .frame(width: geo.size.width / 8 * CGFloat(vm.stepsDone))
                        }
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
                PhotosPicker(selection: photo, matching: .images, photoLibrary: .shared()) {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(.rect(cornerRadius: 20))
                }
            } else {
                PhotosPicker(selection: photo, matching: .images, photoLibrary: .shared()) {
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
                            Text(option == .noSorting ? "None" : option.rawValue.capitalized)
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
                            Text(option.rawValue)
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
                        .animation(.spring, value: vm.ingredients[index].measureMethod)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Steps")
                .font(.custom(Constants.appFontBold, size: 20))
                .foregroundStyle(!vm.steps[0].instruction.isEmpty ? .specialWhite : .specialLightGray)
            
            ForEach(vm.steps.indices, id: \.self) { index in
                StrokedTextfield(
                    systemName: .pen,
                    placeholder: "Step \(vm.steps[index].stepNumber)",
                    text: $vm.steps[index].instruction,
                    lineLimit: 15,
                    focus: $state
                )
                .padding(.bottom, 4)

                ZStack {
                    if let thumbnail = vm.stepUIImages[index] {
                        PhotosPicker(selection: $vm.stepImages[index], matching: .images, photoLibrary: .shared()) {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .clipShape(.rect(cornerRadius: 20))
                        }
                    } else {
                        PhotosPicker(selection: $vm.stepImages[index], matching: .images) {
                            PhotoPickerLabel()
                        }
                    }
                }
                .onChange(of: vm.stepImages[index]) { _, newValue in
                    Task {
                        do {
                            guard let safeValue = newValue else { return }
                            vm.stepUIImages[index] = try await vm.convertToUIImage(image: safeValue)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: vm.steps)
        .padding(.horizontal, 16)
    }
    
    private var hintSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Got a hack to improve this recipe?")
                .font(.custom(Constants.appFontBold, size: 20))
                .foregroundStyle(!vm.hint.isEmpty ? .specialWhite : .specialLightGray)
            
            StrokedTextfield(systemName: .bulb, placeholder: "Drop it here!", text: $vm.hint, lineLimit: 10, focus: $state)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 48)
    }
    
}

#Preview {
    AddNewRecipeView()
}

//
//  AddNewRecipeView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-13.
//

import SwiftUI
import SwiftfulRouting
import PhotosUI

@MainActor
final class AddNewRecipeViewModel: ObservableObject {
    
    @Published var stepsDone: Int = 5
    
    @Published var titleText: String = ""
    @Published var descriptionText: String = ""
    @Published var typeSelection: CategoryOption = .noSorting
    @Published var timeText: String = ""
    @Published var timeMeasure: TimeMeasure = .minutes
    
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

    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: .sectionHeaders) {
                    Section {
                        StrokedTextfield(systemName: .pen, placeholder: "Dish Title", text: $vm.titleText)
                            .padding(.horizontal, 16)
                        
                        photoPickerCell(photo: $vm.mainPhoto, photoUI: vm.mainPhotoUI)
                        
                        typeAndTimeSection
                        
                    } header: {
                        header
                    }
                }
            }
            .scrollIndicators(.hidden)
            .clipped()
            .ignoresSafeArea(.all, edges: .bottom)
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
                    .font(.custom(Constants.appFontMedium, size: 16)), text: $vm.timeText, lineLimit: 1)
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
    
}

#Preview {
    AddNewRecipeView()
}

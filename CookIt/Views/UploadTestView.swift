//
//  UploadTestView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-19.
//

import SwiftUI
import PhotosUI

@MainActor
final class UploadViewModel: ObservableObject {
    
    @Published var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            Task {
                do {
                    try await setImage(from: imageSelection)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?) async throws {
        guard let selection else { return }
        
        let imageData = try await selection.loadTransferable(type: Data.self)
        
        if let imageData {
            try await S3Uploader().uploadImage(imageData: imageData, fileName: "somePhotoForTest")
            self.selectedImage = UIImage(data: imageData)
        }
    }
    
}

struct UploadTestView: View {
    
    @StateObject private var vm = UploadViewModel()
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            if let image = vm.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
            }
            
            PhotosPicker(selection: $vm.imageSelection, matching: .images) {
                Text("Open Your Photo Library")
                    .foregroundStyle(.specialWhite)
            }
        }
    }
}

#Preview {
    UploadTestView()
}

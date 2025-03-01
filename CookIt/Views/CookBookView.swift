//
//  CookBookView.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-01.
//

import SwiftUI
import SwiftfulRouting

@MainActor
final class CookBookViewModel: ObservableObject  {
    
}

struct CookBookView: View {
    
    @Environment(\.router) var router
    @State private var tabSelected: Bool = true
    
    var body: some View {
        ZStack {
            Color.specialBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                    Section {
                        if tabSelected {
                            ForEach(0..<5) { _ in
                                Rectangle()
                                    .fill(.specialPink)
                                    .padding(.horizontal, 16)
                                    .frame(height: 100)
                            }
                        } else {
                            ForEach(0..<5) { _ in
                                Rectangle()
                                    .fill(.specialPurple)
                                    .padding(.horizontal, 16)
                                    .frame(height: 100)
                            }
                        }
                    } header: {
                        VStack(spacing: 8) {
                            ReusableHeader(title: "CookBook", router: router)
                            
                            HStack {
                                Text("My recipes")
                                    .font(.custom(Constants.appFontBold, size: tabSelected ? 20 : 16))
                                    .foregroundStyle(.specialWhite)
                                    .opacity(tabSelected ? 1 : 0.6)
                                    .onTapGesture {
                                        tabSelected = true
                                    }
                                
                                Spacer()
                                
                                Text("Saved")
                                    .font(.custom(Constants.appFontBold, size: tabSelected ? 16 : 20))
                                    .foregroundStyle(.specialWhite)
                                    .opacity(tabSelected ? 0.6 : 1)
                                    .onTapGesture {
                                        tabSelected = false
                                    }
                            }
                            
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)
                        .background(.specialBlack)
                    }
                }
                .animation(.smooth, value: tabSelected)
            }
            .scrollIndicators(.hidden)
            .clipped()
            .ignoresSafeArea(edges: .bottom)
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
}

#Preview {
    CookBookView()
}

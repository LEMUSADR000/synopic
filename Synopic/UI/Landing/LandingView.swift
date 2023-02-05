//
//  LandingView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import SwiftUI

struct LandingView: View {
//    @ObservedObject var viewModel: LandingViewModel
    
    @State private var searchText = ""

    let sections = [
        ViewSection(name: "Section 1", items: ["Item 1", "Item 2", "Item 3"]),
        ViewSection(name: "Section 2", items: ["Item 4", "Item 5", "Item 6"]),
        ViewSection(name: "Section 3", items: ["Item 7", "Item 8", "Item 9"])
    ]
    
    func cornerRadius(index: Int, length: Int) -> UIRectCorner {
        var radius : UIRectCorner
        
        if (index == 0) {
            radius = [.topLeft, .topRight]
        } else if (index == length - 1) {
            radius = [.bottomLeft, .bottomRight]
        } else {
            radius = []
        }
        
        return radius
    }
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ScrollView {
                    LazyVStack(spacing: 20) {
                        HStack {
                            Spacer()
                            SearchBar(text: $searchText)
                                .background(Color(.clear))
                            Spacer()
                        }
                        ForEach(sections) { section in
                            HStack {
                                VStack(spacing: 0) {
                                    HStack {
                                        Text(section.name)
                                            .padding(.bottom, 4)
                                            .padding(.leading, 4)
                                            .font(.system(size: 16, weight: .light))
                                            .foregroundColor(Color(UIColor.systemGray))
                                        Spacer()
                                    }
                                    ForEach(Array(section.items.enumerated()), id: \.element.self) { (i, item) in
                                        HStack {
                                            NavigationLink(item) {
                                                Text(item)
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(UIColor.secondarySystemBackground))
                                            .cornerRadius(20, corners: cornerRadius(index: i, length: section.items.count))
                                        }.frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }.padding(.horizontal, 20)
                                
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .frame(width: geo.size.width)
                    .frame(minHeight: geo.size.height)
                }
            }
            Spacer()
        }
    }
}

extension LandingView {
    struct ViewSection: Identifiable, Hashable {
        var id = UUID()
        var name: String
        var items: [String]
    }
}

struct LandingView_Previews: PreviewProvider {
//    static let appAssembler = AppAssembler()
//    static let viewModel = appAssembler.resolve(LandingViewModel.self)!
    
    static var previews: some View {
        LandingView(/*viewModel: viewModel*/)
    }
}

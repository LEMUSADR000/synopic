//
//  LandingView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import SwiftUI

struct LandingView: View {
    @ObservedObject var viewModel: LandingViewModel
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ScrollView {
                    LazyVStack(spacing: 20) {
                        HStack {
                            Spacer()
                            SearchBar(text: self.viewModel.searchText)
                                .background(Color(.clear))
                            Spacer()
                        }
                        ForEach(self.$viewModel.sections) { section in
                            NotesListView(section: section)
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

struct LandingView_Previews: PreviewProvider {
    static let appAssembler = AppAssembler()
    static let viewModel = appAssembler.resolve(LandingViewModel.self)!
    
    static var previews: some View {
        LandingView(viewModel: viewModel)
    }
}

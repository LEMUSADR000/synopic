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
    ZStack(alignment: .bottom) {
      TabView {
        ScrollView {
          // TODO: Implement search bar
          //            HStack(spacing: 0) {
          //                SearchBar(text: self.viewModel.searchText)
          //                    .background(Color(.clear))
          //            }
          //            .padding(.horizontal, 20)
          //            .padding(.bottom, 10)

          VStack {
            LazyVStack(spacing: 20) {
              ForEach(self.$viewModel.sections) { section in
                GroupListView(
                  section: section,
                  action: { id in self.viewModel.viewGroup.send(id) }
                )
              }
            }
          }
        }
      }
      TabBarContent(viewModel: self.viewModel)
    }
    .navigationTitle("Note Groups")
  }
}

struct LandingView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(LandingViewModel.self)!

  static var previews: some View { LandingView(viewModel: viewModel) }
}

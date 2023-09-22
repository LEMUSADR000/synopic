//
//  LandingView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import SwiftUI

struct LandingView: View {
  static let path = "/"
  @ObservedObject var viewModel: LandingViewModel

  var body: some View {
    ZStack(alignment: .bottom) {
      TabView {
        List {
          ForEach(self.viewModel.sections) { section in
            Section {
              ForEach(section.items) { item in
                GroupRow(
                  item: item,
                  onTap: {
                    self.viewModel.viewGroup.send(item)
                  }
                )
                .transition(.move(edge: .leading))
              }
              .onDelete(perform: delete)
            } header: {
              Text(section.title)
            }.listStyle(SidebarListStyle())
          }
        }.listStyle(InsetGroupedListStyle())
      }
      TabBarContent(viewModel: self.viewModel)
    }
  }
  
  private func delete(at offsets: IndexSet) {
    print(offsets)
  }
}

struct LandingView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(LandingViewModel.self)!

  static var previews: some View {
    LandingView(viewModel: viewModel)
  }
}

//
//  LandingView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import SwiftUI

struct LandingView: View {
  static let path = "/"
  @StateObject var viewModel: LandingViewModel

  var body: some View {
    ZStack(alignment: .bottom) {
      TabView {
        List {
          ForEach(Array(self.viewModel.sections.enumerated()), id: \.0) { index, section in
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
              .onDelete { indexSet in
                self.delete(sectionIndex: index, at: indexSet)
              }
            } header: {
              Text(section.title)
            }.listStyle(SidebarListStyle())
          }
        }.listStyle(InsetGroupedListStyle())
      }
      TabBarContent(viewModel: self.viewModel)
    }
  }

  private func delete(sectionIndex: Int, at offsets: IndexSet) {
    let row = offsets.map { $0 }.first!
    self.viewModel.deleteGroup.send(IndexPath(row: row, section: sectionIndex))
  }
}

struct LandingView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(LandingViewModel.self)!

  static var previews: some View {
    LandingView(viewModel: viewModel)
  }
}

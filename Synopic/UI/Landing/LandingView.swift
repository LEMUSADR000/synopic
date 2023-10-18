//
//  LandingView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import SwiftUI

struct LandingView: View {
  @StateObject var viewModel: LandingViewModel

  var body: some View {
    ZStack(alignment: .bottom) {
      TabView {
        LandingContent(
          sections: self.$viewModel.sections,
          onDelete: self.delete,
          onTap: { group in
            self.viewModel.viewGroup.send(group)
          }
        )
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

//
//  LandingView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import SwiftUI

struct LandingView: View {
  let viewModel: LandingViewModel

  var body: some View {
    ZStack(alignment: .bottom) {
      TabView {
        ViewContent(viewModel: self.viewModel)
      }
      TabBarContent(viewModel: self.viewModel)
    }
  }

  private func delete(sectionIndex: Int, at offsets: IndexSet) {
    let row = offsets.map { $0 }.first!
    self.viewModel.deleteGroup.send(IndexPath(row: row, section: sectionIndex))
  }
}

#Preview {
  LandingView(viewModel: AppAssembler().resolve(LandingViewModel.self)!)
}

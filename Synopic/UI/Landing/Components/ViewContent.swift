//
//  Content.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/16/23.
//

import SwiftUI

struct ViewContent: View {
  @StateObject var viewModel: LandingViewModel

  private let columns: Int = 2
  private let spacing: CGFloat = 20.0

  func computeWidth(_ width: Double) -> Double {
    let totalWidth: Double = width - Double(columns) * spacing

    return totalWidth * (2 / 3)
  }

  var body: some View {
    GeometryReader { geo in
      ScrollView {
        ForEach(0 ..< self.viewModel.sectionCount, id: \.self) { i in
          LazyVStack(alignment: .leading, spacing: 0) {
            HStack {
              Text(self.viewModel.sections[i].title.uppercased())
                .font(.caption)
                .padding(.leading, spacing)
              Spacer()
            }
            GroupGrid(
              items: self.$viewModel.sections[i].items,
              onTap: self.viewModel.viewGroup.send,
              width: computeWidth(geo.size.width),
              columns: columns,
              spacing: spacing
            )
            Spacer().frame(height: spacing * 2)
          }
        }
      }
    }
  }
}

#Preview {
  let sections = [
    ViewSection(
      title: "Today", items: [
        Group(
          title: "Very long name made purely to test what it would look like",
          author: "Very long author to test what this would look like as well",
          childCount: 100
        ),
        Group(title: "Book2", author: "Author2"),
        Group(title: "Book3", author: "Author3"),
        Group(title: "Book4", author: "Author4"),
        Group(title: "Book5", author: "Author5"),
        Group(title: "Book6", author: "Author6"),
        Group(title: "Book7", author: "Author7"),
        Group(title: "Book8", author: "Author8"),
        Group(title: "Book9", author: "Author9"),
        Group(title: "Book10", author: "Author10"),
      ]
    ),
    ViewSection(
      title: "Yesterday", items: [
        Group(title: "Book1", author: "Author1"),
        Group(title: "Book2", author: "Author2"),
        Group(title: "Book3", author: "Author3"),
        Group(title: "Book4", author: "Author4"),
      ]
    ),
    ViewSection(
      title: "Last Week", items: [
        Group(title: "Book1", author: "Author1"),
        Group(title: "Book2", author: "Author2"),
        Group(title: "Book3", author: "Author3"),
        Group(title: "Book4", author: "Author4"),
      ]
    ),
  ]

  return ViewContent(
    viewModel: {
      let model = AppAssembler().resolve(LandingViewModel.self)!
      model.sections = sections
      return model
    }()
  )
}

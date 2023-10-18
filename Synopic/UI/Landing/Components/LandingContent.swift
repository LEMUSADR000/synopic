//
//  LandingContent.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/16/23.
//

import SwiftUI

struct LandingContent: View {
  @Binding var sections: Int
  @StateObject var viewModel: LandingViewModel

  private let columns: Int = 2
  private let spacing: CGFloat = 20.0

  func computeWidth(_ width: Double) -> Double {
    let totalWidth: Double = width - Double(columns) * spacing

    return totalWidth * (2 / 3)
  }

  private func delete(sectionIndex: Int, at offsets: IndexSet) {
    let row = offsets.map { $0 }.first!
    viewModel.deleteGroup.send(IndexPath(row: row, section: sectionIndex))
  }

  var body: some View {
    GeometryReader { geo in
      ScrollView {
        ForEach(0 ..< self.sections, id: \.self) { i in
          VStack(alignment: .leading) {
            HStack {
              Text(self.viewModel.sections[i].title)
                .font(.caption2)
                .padding(.leading, 10)
              Spacer()
            }
            LandingSection(
              items: self.$viewModel.sections[i].items,
              onDelete: { indexSet in
                self.delete(sectionIndex: i, at: indexSet)
              },
              onTap: self.viewModel.viewGroup.send,
              width: computeWidth(geo.size.width),
              columns: columns,
              spacing: spacing
            )
          }
        }
        .listRowSeparator(.hidden)
      }
    }
  }
}

#Preview {
  let sections = [
    ViewSection(
      title: "Today", items: [
        Group(title: "Book1", author: "Author1"),
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

  return LandingContent(
    sections: .constant(sections.count),
    viewModel: {
      let model = AppAssembler().resolve(LandingViewModel.self)!
      model.sections = sections
      return model
    }()
  )
}

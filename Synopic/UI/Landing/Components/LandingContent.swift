//
//  LandingContent.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/16/23.
//

import SwiftUI

struct LandingContent: View {
  @Binding var sections: [ViewSection]
  let onDelete: (Int, IndexSet) -> Void
  let onTap: (Group) -> Void

  private let columns: Int = 2
  private let spacing: CGFloat = 20.0

  func computeWidth(width: Double) -> Double {
    let totalWidth: Double = width - Double(columns) * spacing

    return totalWidth * (2 / 3)
  }

  var body: some View {
    GeometryReader { geo in
      ScrollView {
        ForEach(Array(self.sections.enumerated()), id: \.1) { index, section in
          Spacer().frame(height: geo.size.width * (1 / 12))
          HStack {
            Text(section.title)
              .font(.caption2)
              .padding(.bottom, 4)
              .padding(.leading, 10)
            Spacer()
          }
          LandingSection(
            items: section.items,
            onDelete: { indexSet in self.onDelete(index, indexSet) },
            onTap: self.onTap,
            width: computeWidth(width: geo.size.width),
            columns: columns,
            spacing: spacing
          )
          Spacer().frame(height: geo.size.width * (1 / 12))
        }
        .listRowSeparator(.hidden)
      }
    }
  }
}

#Preview {
  LandingContent(
    sections: .constant([
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
    ]),
    onDelete: { _, _ in },
    onTap: { _ in }
  )
}

//
//  GroupGrid.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/16/23.
//

import SwiftUI

struct GroupGrid: View {
  @Binding var items: [Group]
  let onTap: (Group) -> Void

  let width: Double
  let columns: Int
  let spacing: CGFloat

  private var threeColumnGrid: [GridItem] {
    Array(repeating: GridItem(spacing: 0), count: columns)
  }

  var body: some View {
    LazyVGrid(columns: threeColumnGrid, alignment: .leading, spacing: 0) {
      ForEach(Array(items.enumerated()), id: \.1) { _, item in
        HStack {
          Button(action: { self.onTap(item) }) {
            GroupCard(
              title: item.title,
              author: item.author,
              noteCount: item.childCount,
              theme: item.usableColor,
              width: width
            )
          }
          .clipShape(RoundedRectangle(cornerRadius: 20))
          .foregroundColor(Color(UIColor.label))
          .shadow(color: Color(.systemGray4), radius: 5, x: 0, y: 0)
        }
        .padding(.horizontal, spacing / 2)
        .padding(.vertical, spacing / 2)
      }
    }
  }
}

#Preview {
  GroupGrid(
    items: .constant([
      Group(title: "Book1", author: "Author1"),
      Group(title: "Book2", author: "Author2"),
      Group(title: "Book3", author: "Author3"),
      Group(title: "Book1", author: "Author1"),
      Group(title: "Book2", author: "Author2"),
      Group(title: "Book3", author: "Author3"),
      Group(title: "Book1", author: "Author1"),
      Group(title: "Book2", author: "Author2"),
      Group(title: "Book3", author: "Author3"),
    ]),
    onTap: { _ in },
    width: 250,
    columns: 2,
    spacing: 20
  )
}

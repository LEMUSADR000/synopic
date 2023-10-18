//
//  LandingSection.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/16/23.
//

import SwiftUI

struct LandingSection: View {
  @Binding var items: [Group]
  let onDelete: (IndexSet) -> Void
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
            ZStack(alignment: .top) {
              Rectangle()
                .frame(height: width)
                .foregroundColor(.white)
              Rectangle()
                .frame(height: width * (2 / 3), alignment: .top)
                .foregroundColor(item.usableColor)
              VStack(alignment: .center) {
                Text(item.title.capitalized)
                  .font(.headline.monospaced())
                  .foregroundColor(.primary.opacity(0.6))
                  .minimumScaleFactor(0.1)
                  .multilineTextAlignment(.center)
                Spacer().frame(height: 4)
                Text(item.author.capitalized)
                  .font(.subheadline.monospaced())
                  .foregroundColor(.primary.opacity(0.5))
                  .minimumScaleFactor(0.1)
                  .multilineTextAlignment(.center)
              }
              .frame(height: width * (2 / 3))
            }
          }
          .clipShape(RoundedRectangle(cornerRadius: 20))
          .foregroundColor(Color(UIColor.label))
          .shadow(color: Color(.systemGray4), radius: 5, x: 0, y: 0)
        }
        .padding(.horizontal, spacing / 2)
        .padding(.vertical, spacing / 2)
      }
      .onDelete(perform: onDelete)
    }
  }
}

#Preview {
  LandingSection(
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
    onDelete: { _ in },
    onTap: { _ in },
    width: 300,
    columns: 2,
    spacing: 20
  )
}

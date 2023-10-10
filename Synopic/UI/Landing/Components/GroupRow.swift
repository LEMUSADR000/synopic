//
//  GroupRow.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import CoreData
import SwiftUI

struct GroupRow: View {
  var item: Group
  let onTap: () -> Void

  var body: some View {
    Button(
      action: self.onTap,
      label: {
        HStack {
          GroupCoverImageView(image: .constant(item.imageName))
          Spacer().frame(width: 15)
          VStack(alignment: .leading, spacing: 0) {
            Text(item.title).font(.headline)

            if !item.author.isEmpty {
              Text("by   ")
                .font(.footnote).foregroundColor(.gray.opacity(0.5))
                + Text(item.author)
                .font(.subheadline).foregroundColor(.gray)
            }
          }
        }
      }
    )
    .foregroundColor(Color(UIColor.label))
  }
}

struct GroupRow_Previews: PreviewProvider {
  static let date = Date()
  static let group = Group(
    id: nil,
    lastEdited: date,
    title: "Lion's King",
    author: "Jamal Lahoover",
    childCount: 0,
    imageName: "lion_king_cover"
  )

  static var previews: some View { GroupRow(item: group, onTap: {}) }
}

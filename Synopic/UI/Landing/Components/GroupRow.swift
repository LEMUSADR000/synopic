//
//  GroupRow.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import SwiftUI

struct GroupRow: View {
  var item: NoteGroup
  let onTap: (String) -> Void

  var body: some View {
    Button(
      action: {
        self.onTap(item.id)
      },
      label: {
        HStack(alignment: .top) {
          GroupCoverImageView(image: item.image)
          Spacer().frame(width: 15)
          VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 8)
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
  static let group = NoteGroup(
    created: date,
    title: "Lion's King",
    author: "Jamal Lahoover",
    imageName: "lion_king_cover"
  )

  static var previews: some View { GroupRow(item: group, onTap: { _ in }) }
}

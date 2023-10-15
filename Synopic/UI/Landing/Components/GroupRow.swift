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
    HStack(spacing: 0) {
      // HStack + Empty Text used for bugfix for https://stackoverflow.com/questions/75046730/swiftui-list-divider-unwanted-inset-at-the-start-when-non-text-component-is-u
      Text("").frame(maxWidth: 0)
      Button(
        action: self.onTap,
        label: {
          HStack {
            ZStack {
              Rectangle()
                .foregroundColor(Color(UIColor.secondarySystemBackground))
                .aspectRatio(contentMode: .fill)
                .cornerRadius(4)
              if let image = item.imageURL {
                GroupCoverImageView(image: .constant(image))
              } else {
                VStack(alignment: .center) {
                  Spacer()
                  Text(item.title).font(.system(size: 12)).multilineTextAlignment(.center)
                  Spacer().frame(height: 4)
                  if !item.author.isEmpty {
                    Text("by")
                      .font(.system(size: 8)).foregroundColor(.black.opacity(0.5))
                    Text(item.author)
                      .font(.system(size: 8)).foregroundColor(.black)
                      .multilineTextAlignment(.center)
                  }
                  Spacer()
                }
              }
            }
            .frame(width: 70, height: 70, alignment: .center)
            if item.imageURL != nil {
              VStack(alignment: .center) {
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
        }
      )
      .foregroundColor(Color(UIColor.label))
    }
  }
}

struct GroupRow_Previews: PreviewProvider {
  static let date = Date()
  static let group = Group(
    id: nil,
    lastEdited: date,
    title: "Big Mutliline Name",
    author: "Bigger Multiline Name with Even More Text",
    childCount: 0,
    imageName: nil
  )

  static var previews: some View { GroupRow(item: group, onTap: {}) }
}

//
//  GroupListView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import Combine
import SwiftUI

struct GroupListView: View {
  @Binding var section: ViewSection
  let action: (String) -> Void

  func cornerRadius(index: Int, length: Int) -> UIRectCorner {
    var radius: UIRectCorner

    if index == 0 {
      radius = [.topLeft, .topRight]
    } else if index == length - 1 {
      radius = [.bottomLeft, .bottomRight]
    } else {
      radius = []
    }

    return radius
  }

  var body: some View {
    HStack {
      LazyVStack(spacing: 0) {
        HStack {
          Spacer().frame(width: 5)
          Text(section.title)
            .padding(.bottom, 4)
            .padding(.leading, 4)
            .font(.system(size: 16, weight: .light))
            .foregroundColor(Color(UIColor.systemGray))
          Spacer()
        }
        VStack(spacing: 0) {
          ForEach(Array(section.items.enumerated()), id: \.element.id) { (i, item) in
            VStack(spacing: 0) {

              Button(
                action: { self.action(item.id) },
                label: {
                  GroupRow(item: item)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                })

              if i != section.items.count - 1 {
                Divider().padding(.leading, 20)
              }
            }
          }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
      }
      .padding(.horizontal, 20)
    }
  }
}

struct GroupListView_Previews: PreviewProvider {
  static let date = Date()
  static let items = [
    NoteGroup(created: date, title: "Lion's King", author: "Lion Writer"),
    NoteGroup(created: date.adding(hours: -2), title: "Enders Game", author: .empty),
    NoteGroup(created: date.adding(hours: -4), title: "Star Wars", author: "George Lucas"),
  ]

  static let viewSection = ViewSection(created: date, items: items)

  static var previews: some View {
    GroupListView(section: .constant(viewSection), action: { _ in })
  }
}

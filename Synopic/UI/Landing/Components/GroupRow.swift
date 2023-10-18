////
////  GroupRow.swift
////  Synopic
////
////  Created by Adrian Lemus on 2/5/23.
////
//
//import CoreData
//import SwiftUI
//
//struct GroupRow: View {
//  var item: Group
//  let onTap: () -> Void
//
//  var body: some View {
//    HStack(spacing: 0) {
//      // HStack + Empty Text used for bugfix for https://stackoverflow.com/questions/75046730/swiftui-list-divider-unwanted-inset-at-the-start-when-non-text-component-is-u
//      Text("").frame(maxWidth: 0)
//      Button(
//        action: self.onTap,
//        label: {
//          HStack {
//            ZStack {
//              if let image = item.imageURL {
//                GroupCoverImageView(image: .constant(image))
//              } else {
//                VStack(alignment: .center) {
//                  Text(item.title)
//                    .font(.headline)
//                    .minimumScaleFactor(0.1)
//                    .multilineTextAlignment(.center)
//                  Spacer().frame(height: 4)
//                  if !item.author.isEmpty {
//                    Text("by")
//                      .font(.footnote)
//                      .minimumScaleFactor(0.1)
//                      .font(.footnote).foregroundColor(.gray.opacity(0.5))
//                    Text(item.author)
//                      .font(.subheadline)
//                      .foregroundColor(.gray)
//                      .minimumScaleFactor(0.1)
//                      .multilineTextAlignment(.center)
//                  }
//                }.padding(2.5)
//              }
//            }
//            .frame(width: 70, height: 70, alignment: .center)
//            if item.imageURL != nil {
//              VStack(alignment: .center) {
//                Text(item.title).font(.headline)
//                if !item.author.isEmpty {
//                  Text("by   ")
//                    .font(.footnote).foregroundColor(.gray.opacity(0.5))
//                    + Text(item.author)
//                    .font(.subheadline).foregroundColor(.gray)
//                }
//              }
//            }
//          }
//        }
//      )
//      .foregroundColor(Color(UIColor.label))
//    }
//  }
//}
//
//struct GroupRow_Previews: PreviewProvider {
//  static let date = Date()
//  static let group = Group(
//    id: nil,
//    lastEdited: date,
//    title: "Big Mutliline Name",
//    author: "Bigger Multiline Name with Even More Text",
//    childCount: 0,
//    theme: Color.generateRandomPastelColor()
//  )
//
//  static var previews: some View { GroupRow(item: group, onTap: {}) }
//}

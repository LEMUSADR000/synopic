////
////  NoteSection.swift
////  Synopic
////
////  Created by Adrian Lemus on 2/13/23.
////
//
//import SwiftUI
//
//struct NoteSection<Content>: View where Content: View {
//  @Binding var section: ViewSection
//  let destinationForId: (String) -> any View
//
//  let @ViewBuilder destinationForId: () -> Content
//
//  var body: some View {
//    Section {
//      ForEach($section.items) { item in
//        NavigationLink(destination: destinationForId(item.id)) {
//          GroupRow(item: item)
//        }
//      }
//    } header: {
//      Text(section.title)
//    }
//  }
//}
//
//struct NoteSection_Previews: PreviewProvider {
//  static let date = Date()
//  static let items = [
//    NoteGroup(created: date, title: "Lion's King", author: "Lion Writer"),
//    NoteGroup(
//      created: date.adding(hours: -2),
//      title: "Enders Game",
//      author: .empty
//    ),
//    NoteGroup(
//      created: date.adding(hours: -4),
//      title: "Star Wars",
//      author: "George Lucas"
//    ),
//  ]
//
//  static let viewSection = ViewSection(created: date, items: items)
//
//
//  static var previews: some View {
//    NoteSection(section: .constant(viewSection), action: { _ in })
//  }
//}

//
//  NotesListView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import SwiftUI

struct NotesListView: View {
    @Binding var section: ViewSection
    
    func cornerRadius(index: Int, length: Int) -> UIRectCorner {
        var radius : UIRectCorner
        
        if (index == 0) {
            radius = [.topLeft, .topRight]
        } else if (index == length - 1) {
            radius = [.bottomLeft, .bottomRight]
        } else {
            radius = []
        }
        
        return radius
    }
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer().frame(width: 5)
                    Text(section.title)
                        .padding(.bottom, 4)
                        .padding(.leading, 4)
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(Color(UIColor.systemGray))
                    Spacer()
                }
                ForEach(Array(section.items.enumerated()), id: \.element.self) { (i, item) in
                    VStack(spacing: 0) {
                        GroupRow(item: item)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20, corners: cornerRadius(index: i, length: section.items.count))
                        
                        if (i != section.items.count - 1) {
                            Divider()
                        }
                    }
                }
            }.padding(.horizontal, 20)

            Spacer()
        }
    }
}

struct NotesListView_Previews: PreviewProvider {
    static let title = "Today"
    static let date = Date()
    static let items = [
        NoteGroup(created: date, title: "Lion's King"),
        NoteGroup(created: date.adding(hours: -2), title: "Enders Game"),
        NoteGroup(created: date.adding(hours: -4), title: "Star Wars"),
    ]
    
    static let viewSection = ViewSection(title: title, items: items)
    
    static var previews: some View {
        NotesListView(section: .constant(viewSection))
    }
}

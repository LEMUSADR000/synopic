//
//  ExpandingCardView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/29/23.
//

import SwiftUI

struct ExpandingCardView<Content>: View where Content: View {
    var background: Color
    private var child: Content
    
    init(background: Color, @ViewBuilder content: () -> Content) {
        self.background = background
        self.child = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(background)
            child
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct ExpandingCardView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandingCardView(background: .gray.opacity(0.2)) {
            Spacer().frame(minHeight: 200)
        }
    }
}

//
//  ImagePreviewView.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/22/22.
//

import SwiftUI

struct ImagePreviewView: View {
    @Binding var image: Image?
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct ImagePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePreviewView(image: .constant(Image(systemName: "pencil")))
    }
}

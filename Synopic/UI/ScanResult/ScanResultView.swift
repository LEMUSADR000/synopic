//
//  ScanResultView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/29/23.
//

import SwiftUI

struct ScanResultView: View {
    var result: LandingViewResult
    
    var body: some View {
        ZStack {
            ExpandingCardView(background: result.background.opacity(0.5)) {
                HStack(spacing: 20) {
                    VStack {
                        GeometryReader { geometry in
                            result.image
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }.padding()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    
                    VStack {
                        Text(result.text)
                    }.frame(minWidth: 0, maxWidth: .infinity)
                }
                .padding()
                .multilineTextAlignment(.center)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding()
    }
}

struct ScanResultView_Previews: PreviewProvider {
    static let documentScanResult = LandingViewResult(background: .green, image: Image(systemName: "pencil"), text: "This is a big\nText result item\nWith multiple lines\nwho knows it could be a lot bigger\nbut for now this is it\nmayne dios-mio mio mio is dios-mio")
    static var previews: some View {
        ScanResultView(result: documentScanResult)
    }
}

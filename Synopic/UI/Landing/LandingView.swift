//
//  LandingView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import SwiftUI

struct LandingView: View {
    @ObservedObject var viewModel: LandingViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollView in
                ScrollView {
                    ForEach(self.viewModel.results) { result in
                        ScanResultView(result: result)
                            .foregroundColor(.white)
                    }
                    .onChange(of: self.viewModel.results) { results in
                        withAnimation(.easeIn(duration: 0.5)) {
                            scrollView.scrollTo("button_identifier", anchor: .bottom)
                        }
                    }
                    
                    Button(action: self.viewModel.openScanSheet) {
                        ExpandingCardView(background: .gray.opacity(0.2)) {
                            Image(systemName: "plus")
                                .scaledToFit()
                                .padding(.vertical, 20)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .padding(.horizontal, 50)
                        .padding(.vertical, 20)
                    }
                    .foregroundColor(.white)
                    .id("button_identifier")
                }
            }
        }
    }
}

struct LandingView_Previews: PreviewProvider {
    static let appAssembler = AppAssembler()
    static let viewModel = appAssembler.resolve(LandingViewModel.self)!
    
    static var previews: some View {
        LandingView(viewModel: viewModel)
    }
}

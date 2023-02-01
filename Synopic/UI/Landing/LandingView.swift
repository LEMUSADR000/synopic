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
                    LazyVStack {
                        ForEach(0..<self.viewModel.results.count + 1, id: \.self) { i in
                            if (i == self.viewModel.results.count) {
                                Button(action: self.viewModel.openScanSheet) {
                                    ExpandingCardView(background: .gray.opacity(0.2)) {
                                        Image(systemName: "plus")
                                            .scaledToFit()
                                            .padding(20)
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.gray.opacity(0.5))
                                    }.padding(50)
                                }.foregroundColor(.white)
                            } else {
                                ScanResultView(result: self.viewModel.results[i])
                                    .foregroundColor(.white)
                            }
                        }.onChange(of: self.viewModel.results, perform: { results in
                            withAnimation(.linear(duration: 0.25)) {
                                scrollView.scrollTo(results.count, anchor: .bottom)
                            }
                        })
                    }
                    .frame(minHeight: geometry.size.height)
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

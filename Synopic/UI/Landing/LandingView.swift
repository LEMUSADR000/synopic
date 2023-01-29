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
        NavigationView {
            VStack {
                ScrollView {
                    ZStack {
                        LazyVStack {
                            ForEach(self.viewModel.results.indices, id: \.self) { i in
                                ScanResultView(result: self.viewModel.results[i])
                                    .transition(.slide)
                                    .zIndex(0)
                            }
                        }
                        .id(UUID())
                        .transition(AnyTransition.opacity.animation(.default))
                    }
                    .padding()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: self.viewModel.openScanSheet) {
                        Text("Start Scanning")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Capsule().fill(Color.blue))
                }
                .padding()
            }
            .navigationBarTitle("Text Recognition")
        }.navigationBarHidden(true)
    }
}

struct LandingView_Previews: PreviewProvider {
    static let appAssembler = AppAssembler()
    static let viewModel = appAssembler.resolve(LandingViewModel.self)!
    
    static var previews: some View {
        LandingView(viewModel: viewModel)
    }
}

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
                            ForEach(self.viewModel.items, id: \.self) {
                                Text($0)
                            }
                        }
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

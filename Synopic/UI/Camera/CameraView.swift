//
//  CameraView.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/18/22.
//

import SwiftUI

struct CameraView: View {
    @ObservedObject var model: CameraViewModel
    @State private var validatingImage: Bool = false
    
    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack { content }
        } else {
            NavigationView { content }
        }
    }
    
    private var content: some View {
        GeometryReader { geometry in
            ImagePreviewView(image: $model.previewImage)
                .overlay(alignment: .bottom) {
                    buttons
                }
                .background(.black)
        }
        .navigationTitle("Camera")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .statusBar(hidden: true)
        .task {
            await self.model.start()
        }
        .onReceive(self.model.validatingImage.receive(on: .main)) {
            validatingImage = $0
        }
    }
    
    private var buttons: some View {
        HStack {
            if !validatingImage {
                captureButton
            } else {
                validateButtons
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0))
    }
    
    private var captureButton: some View {
        Button(action: self.model.capturePhoto) {
            ZStack {
                Circle()
                    .strokeBorder(.white, lineWidth: 3)
                    .frame(width: 62, height: 62)
                Circle()
                    .fill(.red)
                    .frame(width: 50, height: 50)
            }
        }
    }
    
    private var validateButtons: some View {
        HStack(spacing: 30) {
            Button(action: self.model.acceptPhoto){
                Text("OK")
                .frame(width: 100, height: 50, alignment: .center)
                .background(.green)
                .cornerRadius(10)
                .font(.system(size: 20, weight: .bold))
            }
            Button(action: self.model.denyPhoto){
                Text("RETAKE")
                .frame(width: 100, height: 50, alignment: .center)
                .background(.red)
                .cornerRadius(10)
                .font(.system(size: 20, weight: .bold))
            }
        }
        .font(.headline.bold())
        .foregroundColor(.white)
    }
    
}

struct CameraView_Previews: PreviewProvider {
    static let appAssembler = AppAssembler()
    static let viewModel = appAssembler.resolve(CameraViewModel.self)!
    
    static var previews: some View {
        CameraView(model: viewModel)
    }
}

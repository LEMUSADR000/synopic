//
//  CameraView.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/10/23.
//

import Combine
import SwiftUI

struct CameraView: View {
  @StateObject var model: CameraViewModel

  var body: some View {
    ImagePreviewView(raw: $model.previewImage)
      .overlay(alignment: .bottom) {
        ButtonSet(
          validatingImage: self.$model.validatingImage,
          onButtonTap: { type in
            self.model.tapCameraButton.send(type)
          }
        )
      }
      .background(.black)
      .navigationTitle("Camera")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarHidden(true)
      .ignoresSafeArea()
      .statusBar(hidden: true)
      .task {
        await self.model.start()
      }
      .onDisappear {
        self.model.stop()
      }
  }
}

struct ButtonSet: View {
  @Binding var validatingImage: Bool
  let onButtonTap: (CameraButtonTap) -> ()

  var body: some View {
    HStack {
      if !validatingImage {
        captureButton()
          .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity).animation(.easeInOut(duration: 0.35)))
      } else {
        validateButtons()
          .transition(AnyTransition.move(edge: .top).combined(with: .opacity).animation(.easeInOut(duration: 0.35)))
      }
    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 100, trailing: 0))
  }

  @ViewBuilder
  private func captureButton() -> some View {
    Button(action: { onButtonTap(.capture) }) {
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

  @ViewBuilder
  private func validateButtons() -> some View {
    HStack(spacing: 30) {
      Button(action: { onButtonTap(.accept) }) {
        Text("OK")
          .frame(width: 100, height: 50, alignment: .center)
          .background(.green)
          .cornerRadius(10)
          .font(.system(size: 20, weight: .bold))
      }
      Button(action: { onButtonTap(.deny) }) {
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

#Preview {
  CameraView(model: AppAssembler().resolve(CameraViewModel.self)!)
}

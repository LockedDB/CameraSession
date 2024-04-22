//
//  CameraPreview.swift
//  Wrapper for AVCaptureVideoPreviewLayer to make it work in SwiftUI.
//  Wrap it in UIView from UIKit to render it without issue in a body.
//
//  Created by Dani Benet on 16/4/24.
//

import AVFoundation
import SwiftUI

struct CameraPreview: UIViewRepresentable {
 
  let session: AVCaptureSession
 
  // creates and configures a UIKit-based video preview view
  func makeUIView(context: Context) -> VideoPreviewView {
     let view = VideoPreviewView()
     view.backgroundColor = .black
     view.videoPreviewLayer.session = session
     view.videoPreviewLayer.videoGravity = .resizeAspectFill
     return view
  }
 
  // updates the video preview view
  public func updateUIView(_ uiView: VideoPreviewView, context: Context) { }
 
  // UIKit-based view for displaying the camera preview
  class VideoPreviewView: UIView {

     // specifies the layer class used
     override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
     }
  
     // retrieves the AVCaptureVideoPreviewLayer for configuration
     var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
     }
  }
}

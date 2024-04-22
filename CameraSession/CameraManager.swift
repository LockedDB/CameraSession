//
//  CameraManager.swift
//  CameraSession
//
//  Created by Dani Benet on 20/4/24.
//

import SwiftUI
import AVFoundation

enum Status {
    case unconfigured
    case configured
    case denied
    case failed
}

class CameraManager: ObservableObject {
    
    let session = AVCaptureSession()
    
    @Published var status: Status = .unconfigured
    
    // Serial queue to ensure thread safety when working with the camera
    private let sessionQueue = DispatchQueue(label: "com.camera.sessionQueue")

    func configureCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, status == .unconfigured else { return }
            
            session.beginConfiguration()
            
            // Add video input from the device's camera
            setUpVideoInput()
            
            // Add the photo output configuration
            setUpPhotoOutput()
            
            // Commit session configuration
            session.commitConfiguration()
            
            // Start capturing if everything is configured correctly
            startCapturing()
        }
    }

    private func setUpVideoInput() {
        let videoDevice = AVCaptureDevice.default(for: .video)
        
        guard let videoDevice else {
            print("CameraManager: Video device is unavailable.")
            status = .unconfigured
            session.commitConfiguration()
            return
        }
        
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            session.canAddInput(videoDeviceInput)
        else {
            print("CameraManager: Couldn't add video device to capture session.")
            status = .failed
            session.commitConfiguration()
            return
        }
        
        status = .configured
        session.addInput(videoDeviceInput)
    }
    
    private func setUpPhotoOutput() {
        let photoOutput = AVCapturePhotoOutput()
        
        guard session.canAddOutput(photoOutput) else {
            print("CameraManager: Couldn't add photo output to capture session.")
            status = .failed
            session.commitConfiguration()
            return
        }
        
        status = .configured
        session.sessionPreset = .photo
        session.addOutput(photoOutput)
    }
    
    private func startCapturing() {
        
        if (status == .configured) {
            session.startRunning()
        } else if (status == .unconfigured || status == .denied) {
            // error
        }
    }
    
    func stopCapturing() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}

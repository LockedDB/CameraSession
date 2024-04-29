//
//  CameraVM.swift
//  CameraSession
//
//  Created by Dani Benet on 20/4/24.
//

import Foundation
import AVFoundation
import SwiftUI
import Observation

@Observable class CameraVM {
    
    var cameraManager = CameraManager()
    
    // reference to capture session
    var session: AVCaptureSession = .init()
    
    init() {
        // Initialize the session with the cameraManager's session.
        session = cameraManager.session
    }
    
    deinit {
        cameraManager.stopCapturing()
    }
    
    func checkForDevicePermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        
        if (status == .authorized) {
            // Permission granted! Configure the camera session
            configureCamera()
        } else if (status == .notDetermined) {
            // In case the user has not been asked to grant access we request permission
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [self] accepted in
                if accepted {
                    configureCamera()
                } else {
                    cameraManager.status = .failed(CameraError.permissionDenied)
                }
            })
        } else if (status == .denied) {
            cameraManager.status = .failed(CameraError.permissionDenied)
        }
    }
    
    func changeInputDevice(device: AVCaptureDevice) {
        cameraManager.switchCameraInput(newCamera: device)
    }
    
    // Configure the camera through the CameraManager to show a live camera preview.
    func configureCamera() {
        cameraManager.configureCaptureSession()
    }
}

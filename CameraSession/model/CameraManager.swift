import SwiftUI
import AVFoundation
import Observation

@Observable class CameraManager {
    
    let session = AVCaptureSession()
    
    var availableInputDevices: [AVCaptureDevice] = []
    
    var status: CameraStatus = .unconfigured
    
    // Serial queue to ensure thread safety when working with the camera
    private let sessionQueue = DispatchQueue(label: "com.camera.sessionQueue")

    func configureCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            do {
                try self.setUpVideoInput()
                try self.setUpPhotoOutput()
                
                session.sessionPreset = .photo
                
                self.session.commitConfiguration()
                self.status = .configured
                self.startCapturing()
            } catch {
                self.session.commitConfiguration()
                self.status = .failed(error as! CameraError)
            }
        }
    }
    
    private func setUpPhotoOutput() throws {
        let photoOutput = AVCapturePhotoOutput()
        
        guard session.canAddOutput(photoOutput) else {
            throw CameraError.outputSetupFailed
        }
        
        session.addOutput(photoOutput)
    }
    
    private func startCapturing() {
        if session.isRunning {
            print("CameraManager: Session is already running.")
            return
        }
        
        session.startRunning()
    }
    
    func stopCapturing() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.session.isRunning else { return }
            self.session.stopRunning()
            print("CameraManager: Session stopped.")
        }
    }
}

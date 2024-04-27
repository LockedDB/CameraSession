import SwiftUI
import AVFoundation

enum CameraError: Error {
    case unconfigured
    case deviceUnavailable
    case inputSetupFailed
    case outputSetupFailed
    case startCaptureFailed
}

extension CameraError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .unconfigured:
                return NSLocalizedString("The session is not configured yet.", comment: "")
            case .deviceUnavailable:
                return NSLocalizedString("The camera device is unavailable.", comment: "")
            case .inputSetupFailed:
                return NSLocalizedString("Failed to set up camera input.", comment: "")
            case .outputSetupFailed:
                return NSLocalizedString("Failed to set up camera output.", comment: "")
            case .startCaptureFailed:
                return NSLocalizedString("Failed to start camera capture.", comment: "")
        }
    }
}

enum Status: Equatable {
    case unconfigured
    case configured
    case denied
    case failed(Error)
    
    static func == (lhs: Status, rhs: Status) -> Bool {
        switch (lhs, rhs) {
        case (.unconfigured, .unconfigured), (.configured, .configured), (.denied, .denied):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

class CameraManager: ObservableObject {
    
    let session = AVCaptureSession()
    
    @Published var status: Status = .unconfigured
    
    // Serial queue to ensure thread safety when working with the camera
    private let sessionQueue = DispatchQueue(label: "com.camera.sessionQueue")

    func configureCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            do {
                try self.setUpVideoInput()
                try self.setUpPhotoOutput()
                self.session.commitConfiguration()
                self.status = .configured
                self.startCapturing()
            } catch {
                self.session.commitConfiguration()
                self.status = .failed(error)
            }
        }
    }

    private func setUpVideoInput() throws {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            throw CameraError.deviceUnavailable
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            guard session.canAddInput(videoDeviceInput) else {
                throw CameraError.inputSetupFailed
            }
            session.addInput(videoDeviceInput)
        } catch {
            throw CameraError.inputSetupFailed
        }
    }
    
    private func setUpPhotoOutput() throws {
        let photoOutput = AVCapturePhotoOutput()
        guard session.canAddOutput(photoOutput) else {
            throw CameraError.outputSetupFailed
        }
        session.sessionPreset = .photo
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

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
    
    var availableDevices: [AVCaptureDevice] = []
    
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
        
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
                // The built-in wide angle camera is available on
                // all iPhones. It's the standard rear-facing camera.
                .builtInWideAngleCamera,
                
                // The built-in dual camera is available on iPhone
                // 7 Plus, iPhone 8 Plus, iPhone X, iPhone XS, and
                // iPhone XS Max. It combines input from a wide-angle
                // and a telephoto lens to provide better zoom and
                // depth-of-field capabilities.
                .builtInDualCamera,
                
                // The built-in ultra wide camera is available on
                // iPhone 11 and later. It has a much wider field
                // of view than the wide angle camera.
                .builtInUltraWideCamera
            ]
        
        availableDevices = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified
        ).devices

        // Add the native defined default input
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            throw CameraError.deviceUnavailable
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            session.canAddInput(videoDeviceInput)
            session.addInput(videoDeviceInput)
        } catch {
            
            // If default set up fails, try to set up with other available
            // devices sorted by preference
            do {
                if try addDeviceInput(ofType: .builtInWideAngleCamera) { return }
                
                if try addDeviceInput(ofType: .builtInDualCamera) { return }
                
                if try addDeviceInput(ofType: .builtInUltraWideCamera) { return }
                
                throw CameraError.inputSetupFailed
            } catch {
                throw CameraError.inputSetupFailed
            }
        }
    }
    
    func switchCameraInput(newCamera: AVCaptureDevice) {
        session.beginConfiguration()
        
        // Assuming `currentInput` is the current AVCaptureDeviceInput in the session
        if let currentInput = session.inputs.first as? AVCaptureDeviceInput {
            session.removeInput(currentInput)
        }
        
        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
            } else {
                print("Cannot add new input")
            }
        } catch let error {
            print("Error initializing new camera input: \(error)")
        }
        
        session.commitConfiguration()
    }

    
    private func addDeviceInput(ofType type: AVCaptureDevice.DeviceType) throws -> Bool {
        if let device = availableDevices.first(where: { $0.deviceType == type }) {
            let videoDeviceInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                return true
            }
        }
        return false
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

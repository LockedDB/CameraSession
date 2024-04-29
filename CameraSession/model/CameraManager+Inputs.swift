//
//  CameraManager+Inputs.swift
//  CameraSession
//
//  This extension of CameraManager handles the setup and switching of video input devices for the camera session.
//  Created by Dani Benet on 28/4/24.
//

import Foundation
import AVFoundation

extension CameraManager {
    
    /// Sets up the video input for the camera session.
    /// It tries to configure the session with the default video device and falls back to alternative devices if needed.
    internal func setUpVideoInput() throws {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,    // Standard rear-facing camera on all iPhones.
            .builtInDualCamera,         // Available on iPhone 7 Plus and later models.
            .builtInUltraWideCamera     // Available on iPhone 11 and later models.
        ]
        
        // Discover available devices based on specified device types.
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified
        )
        availableInputDevices = discoverySession.devices
        
        // Attempt to set up the default video device input.
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            throw CameraError.deviceUnavailable
        }
        
        try setUpDeviceInput(for: videoDevice)
    }

    
    /// Attempts to set up the session input with the specified video device.
    /// - Parameter device: The AVCaptureDevice to be used as the input source.
    /// - Throws: Throws `CameraError.inputSetupFailed` if the input cannot be added to the session.
    private func setUpDeviceInput(for device: AVCaptureDevice) throws {
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
            } else {
                throw CameraError.inputSetupFailed
            }
        } catch {
            print("CameraManager: Default device set up failed. Trying other options...")
            // If the default device setup fails, attempt to set up other available devices.
            try setUpAlternativeDeviceInput()
        }
    }

    /// Tries to set up an alternative video device input from a list of preferred device types.
    /// - Throws: Throws `CameraError.inputSetupFailed` if no suitable device can be configured.
    private func setUpAlternativeDeviceInput() throws {
        let preferredDeviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,    // Standard rear-facing camera on all iPhones.
            .builtInDualCamera,         // Available on iPhone 7 Plus and later models.
            .builtInUltraWideCamera     // Available on iPhone 11 and later models.
        ]
        
        for deviceType in preferredDeviceTypes {
            if let device = availableInputDevices.first(where: { $0.deviceType == deviceType }) {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(videoDeviceInput) {
                        session.addInput(videoDeviceInput)
                        return  // Successfully added an input, exit the function.
                    }
                } catch {
                    continue  // Try the next device type.
                }
            }
        }
        
        // If no devices could be set up, throw an error.
        throw CameraError.inputSetupFailed
    }
    
    /// Switches the camera input to a new device.
    /// - Parameter newCamera: The new AVCaptureDevice to switch to.
    /// - Throws: Throws `CameraError.inputSetupFailed` if the new input cannot be added.
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
                throw CameraError.inputSetupFailed
            }
        } catch let error {
            status = .failed(error as! CameraError)
        }
        
        session.commitConfiguration()
    }
}

//
//  CameraStatus.swift
//  CameraSession
//
//  Created by Dani Benet on 28/4/24.
//

import Foundation

enum CameraError: Error {
    case unconfigured
    case deviceUnavailable
    case inputSetupFailed
    case outputSetupFailed
    case startCaptureFailed
    case permissionDenied
}

extension CameraError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return NSLocalizedString("Camera access was denied. Please enable camera access in the settings.", comment: "")
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
    struct CameraStatusInfo {
        let label: String
        let systemImage: String
    }

    var info: CameraStatusInfo {
        switch self {
        case .permissionDenied:
            return CameraStatusInfo(label: NSLocalizedString("Permission Denied", comment: ""), systemImage: "xmark.shield")
        case .unconfigured:
            return CameraStatusInfo(label: NSLocalizedString("Unconfigured", comment: ""), systemImage: "gearshape")
        case .deviceUnavailable:
            return CameraStatusInfo(label: NSLocalizedString("Device Unavailable", comment: ""), systemImage: "camera.slash")
        case .inputSetupFailed:
            return CameraStatusInfo(label: NSLocalizedString("Input Setup Failed", comment: ""), systemImage: "arrow.triangle.2.circlepath.camera")
        case .outputSetupFailed:
            return CameraStatusInfo(label: NSLocalizedString("Output Setup Failed", comment: ""), systemImage: "arrow.triangle.2.circlepath.camera.fill")
        case .startCaptureFailed:
            return CameraStatusInfo(label: NSLocalizedString("Start Capture Failed", comment: ""), systemImage: "camera.badge.ellipsis")
        }
    }
}

/// The status of the camera manager.
/// - unconfigured: The camera manager is not configured yet.
/// - configured: The camera manager is configured and ready to use.
/// - denied: The user denied camera access.
/// - failed: The camera manager failed to configure.
enum CameraStatus: Equatable {
    case unconfigured
    case configured
    case failed(CameraError)
    
    static func == (lhs: CameraStatus, rhs: CameraStatus) -> Bool {
        switch (lhs, rhs) {
        case (.unconfigured, .unconfigured), (.configured, .configured):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

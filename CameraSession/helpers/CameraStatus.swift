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

/// The status of the camera manager.
/// - unconfigured: The camera manager is not configured yet.
/// - configured: The camera manager is configured and ready to use.
/// - denied: The user denied camera access.
/// - failed: The camera manager failed to configure.
enum CameraStatus: Equatable {
    case unconfigured
    case configured
    case denied
    case failed(Error)
    
    static func == (lhs: CameraStatus, rhs: CameraStatus) -> Bool {
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

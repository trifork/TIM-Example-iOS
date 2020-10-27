import Foundation
import LocalAuthentication

extension LABiometryType {
    var biometricIdName: String {
        switch LAContext().biometryType {
        case .faceID:
            return "FaceID"
        case .touchID:
            return "TouchID"
        default:
            return "N/A"
        }
    }
}

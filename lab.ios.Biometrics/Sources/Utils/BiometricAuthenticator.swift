import Foundation
import LocalAuthentication

protocol BiometricAuthenticating: Sendable {
    func authenticate() async throws
}

enum BiometricAuthenticationError: LocalizedError, Equatable, Sendable {
    case unavailable(String)
    case denied
    case cancelled
    case failed(String)

    var errorDescription: String? {
        switch self {
        case let .unavailable(message):
            "Biometric authentication is unavailable: \(message)"
        case .denied:
            "Biometric authentication was not successful."
        case .cancelled:
            "Biometric authentication was cancelled."
        case let .failed(message):
            "Biometric authentication failed: \(message)"
        }
    }
}

struct LocalBiometricAuthenticator: BiometricAuthenticating {
    private let localizedReason: String

    init(
        localizedReason: String = "Authenticate to enter the content area and save a message."
    ) {
        self.localizedReason = localizedReason
    }

    func authenticate() async throws {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) else {
            throw map(error: error, unavailable: true)
        }

        do {
            let authenticated = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: localizedReason
            )
            guard authenticated else {
                throw BiometricAuthenticationError.denied
            }
        } catch let error as BiometricAuthenticationError {
            throw error
        } catch {
            throw map(error: error, unavailable: false)
        }
    }

    private func map(error: (any Error)?, unavailable: Bool) -> BiometricAuthenticationError {
        guard let error else {
            return unavailable ? .unavailable("No reason was supplied by the device.") : .failed("Unknown error.")
        }
        guard let localAuthenticationError = error as? LAError else {
            return unavailable ? .unavailable(error.localizedDescription) : .failed(error.localizedDescription)
        }

        switch localAuthenticationError.code {
        case .userCancel, .appCancel, .systemCancel:
            return .cancelled
        case .authenticationFailed, .userFallback:
            return .denied
        case .biometryNotAvailable, .biometryNotEnrolled, .biometryLockout, .passcodeNotSet:
            return .unavailable(localAuthenticationError.localizedDescription)
        default:
            return unavailable
                ? .unavailable(localAuthenticationError.localizedDescription)
                : .failed(localAuthenticationError.localizedDescription)
        }
    }
}

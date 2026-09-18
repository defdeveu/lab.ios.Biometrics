import Foundation
import Observation

@MainActor
@Observable
final class WelcomeViewModel {
    private(set) var isAuthenticating = false
    var isContentPresented = false
    private(set) var errorMessage: String?

    @ObservationIgnored private let authenticator: any BiometricAuthenticating

    init(authenticator: any BiometricAuthenticating) {
        self.authenticator = authenticator
    }

    func enterContent() async {
        guard !isAuthenticating else {
            return
        }

        isAuthenticating = true
        errorMessage = nil
        defer { isAuthenticating = false }

        do {
            try await authenticator.authenticate()
            isContentPresented = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}

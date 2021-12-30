import Foundation

class WelcomeViewModel: ObservableObject {
    @Published var navigateToContent: Bool = false
    @Published var showError: Bool = false
    @Published var error: String? = nil

    private let biometryPermissionRequester: BiometryPermissionRequesterProtocol

    init(biometryPermissionRequester: BiometryPermissionRequesterProtocol = AppRepository.shared.biometryPermissionRequester) {
        self.biometryPermissionRequester = biometryPermissionRequester
    }

    func enterContent() {
        error = nil

        biometryPermissionRequester.request { [weak self] result in
            switch result {
            case .success:
                self?.navigateToContent = true
            case .failure(let error):
                self?.error = error.description
                self?.showError = true
            }
        }
    }
}

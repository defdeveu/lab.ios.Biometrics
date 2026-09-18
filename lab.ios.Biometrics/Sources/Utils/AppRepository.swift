enum AppRepository {
    @MainActor
    static func makeWelcomeViewModel() -> WelcomeViewModel {
        WelcomeViewModel(authenticator: LocalBiometricAuthenticator())
    }

    @MainActor
    static func makeContentViewModel() -> ContentViewModel {
        ContentViewModel(fileRepository: FileRepository())
    }
}

enum AppRepository {
    @MainActor
    static func makeContentViewModel() -> ContentViewModel {
        ContentViewModel(fileRepository: FileRepository())
    }
}

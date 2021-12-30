import Foundation

// MARK: - Application Services

final class AppRepository {
    static var shared = AppRepository()
    private init() { }

    lazy var fileRepository: FileRepositoryProtocol = {
        FileRepository()
    }()
}

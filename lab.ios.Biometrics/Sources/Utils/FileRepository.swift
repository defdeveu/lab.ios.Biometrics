import Foundation

protocol FileRepositoryProtocol: Sendable {
    func save(message: String, to destination: String) async throws
    func read(from source: String) async throws -> String?
}

enum FileRepositoryError: LocalizedError, Equatable {
    case directoryUnavailable
    case invalidFileName

    var errorDescription: String? {
        switch self {
        case .directoryUnavailable:
            "The app's Documents directory is unavailable."
        case .invalidFileName:
            "The destination must be a single file name."
        }
    }
}

actor FileRepository: FileRepositoryProtocol {
    private let directoryURL: URL?

    init(directoryURL: URL? = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first) {
        self.directoryURL = directoryURL
    }

    func save(message: String, to destination: String) throws {
        let fileURL = try destinationURL(for: destination)
        try message.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    func read(from source: String) throws -> String? {
        let fileURL = try destinationURL(for: source)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        return try String(contentsOf: fileURL, encoding: .utf8)
    }

    private func destinationURL(for fileName: String) throws -> URL {
        guard !fileName.isEmpty,
              fileName != ".",
              fileName != "..",
              (fileName as NSString).lastPathComponent == fileName
        else {
            throw FileRepositoryError.invalidFileName
        }
        guard let directoryURL else {
            throw FileRepositoryError.directoryUnavailable
        }
        return directoryURL.appendingPathComponent(fileName, isDirectory: false)
    }
}

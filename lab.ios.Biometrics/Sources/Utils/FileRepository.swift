import Foundation

protocol FileRepositoryProtocol {
    func save(message: String, to destination: String) -> Bool
    func read(from source: String) -> String?
}

final class FileRepository: FileRepositoryProtocol {
    func save(message: String, to destination: String) -> Bool {
        guard let url = documentDirectoryPath() else { return false }
        let fileURL = url.appendingPathComponent(destination)

        do {
            try message.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            return false
        }

        return true
    }

    func read(from source: String) -> String? {
        guard let url = documentDirectoryPath() else { return nil }
        let fileURL = url.appendingPathComponent(source)

        return try? String(contentsOf: fileURL, encoding: .utf8)
    }

    private func documentDirectoryPath() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

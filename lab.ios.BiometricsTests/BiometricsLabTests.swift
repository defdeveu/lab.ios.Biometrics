import Foundation
import XCTest
@testable import lab_ios_Biometrics

@MainActor
final class FileRepositoryTests: XCTestCase {
    func testRoundTripsUTF8Message() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: directory) }

        let repository = FileRepository(directoryURL: directory)
        try await repository.save(message: "Árvíztűrő tükörfúrógép", to: "message.txt")

        let savedMessage = try await repository.read(from: "message.txt")
        XCTAssertEqual(savedMessage, "Árvíztűrő tükörfúrógép")
    }

    func testRejectsPathTraversal() async {
        let repository = FileRepository(directoryURL: FileManager.default.temporaryDirectory)

        do {
            try await repository.save(message: "message", to: "../message.txt")
            XCTFail("Expected an invalid-file-name error")
        } catch {
            XCTAssertEqual(error as? FileRepositoryError, .invalidFileName)
        }
    }
}

@MainActor
final class ContentViewModelTests: XCTestCase {
    func testSavePublishesReadBackValue() async {
        let repository = RecordingFileRepository()
        let viewModel = ContentViewModel(fileRepository: repository)
        viewModel.message = "Saved message"

        await viewModel.saveMessage()

        XCTAssertEqual(viewModel.savedMessage, "Saved message")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isSaving)
        let writes = await repository.recordedWrites()
        XCTAssertEqual(writes, ["message.txt": "Saved message"])
    }

    func testSavePublishesStorageFailure() async {
        let repository = RecordingFileRepository(error: TestStorageError.failed)
        let viewModel = ContentViewModel(fileRepository: repository)

        await viewModel.saveMessage()

        XCTAssertNil(viewModel.savedMessage)
        XCTAssertEqual(viewModel.errorMessage, TestStorageError.failed.localizedDescription)
        XCTAssertFalse(viewModel.isSaving)
    }
}

private enum TestStorageError: LocalizedError {
    case failed

    var errorDescription: String? {
        "Test storage failed."
    }
}

private actor RecordingFileRepository: FileRepositoryProtocol {
    private var writes: [String: String] = [:]
    private let error: (any Error)?

    init(error: (any Error)? = nil) {
        self.error = error
    }

    func save(message: String, to destination: String) throws {
        if let error {
            throw error
        }
        writes[destination] = message
    }

    func read(from source: String) throws -> String? {
        if let error {
            throw error
        }
        return writes[source]
    }

    func recordedWrites() -> [String: String] {
        writes
    }
}

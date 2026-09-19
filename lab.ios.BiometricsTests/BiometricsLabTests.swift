import Foundation
import Testing
@testable import lab_ios_Biometrics

@MainActor
@Suite
struct FileRepositoryTests {
    @Test
    func roundTripsUTF8Message() async throws {
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
        #expect(savedMessage == "Árvíztűrő tükörfúrógép")
    }

    @Test
    func rejectsPathTraversal() async {
        let repository = FileRepository(directoryURL: FileManager.default.temporaryDirectory)

        do {
            try await repository.save(message: "message", to: "../message.txt")
            Issue.record("Expected an invalid-file-name error")
        } catch {
            #expect(error as? FileRepositoryError == .invalidFileName)
        }
    }
}

@MainActor
@Suite
struct ContentViewModelTests {
    @Test
    func savePublishesReadBackValue() async {
        let repository = RecordingFileRepository()
        let viewModel = ContentViewModel(fileRepository: repository)
        viewModel.message = "Saved message"

        await viewModel.saveMessage()

        #expect(viewModel.savedMessage == "Saved message")
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isSaving)
        let writes = await repository.recordedWrites()
        #expect(writes == ["message.txt": "Saved message"])
    }

    @Test
    func savePublishesStorageFailure() async {
        let repository = RecordingFileRepository(error: TestStorageError.failed)
        let viewModel = ContentViewModel(fileRepository: repository)

        await viewModel.saveMessage()

        #expect(viewModel.savedMessage == nil)
        #expect(viewModel.errorMessage == TestStorageError.failed.localizedDescription)
        #expect(!viewModel.isSaving)
    }
}

@MainActor
@Suite
struct WelcomeViewModelTests {
    @Test
    func successfulAuthenticationPresentsContent() async {
        let viewModel = WelcomeViewModel(
            authenticator: StubBiometricAuthenticator(result: .success(()))
        )

        await viewModel.enterContent()

        #expect(viewModel.isContentPresented)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isAuthenticating)
    }

    @Test
    func deniedAuthenticationKeepsContentClosed() async {
        let viewModel = WelcomeViewModel(
            authenticator: StubBiometricAuthenticator(result: .failure(.denied))
        )

        await viewModel.enterContent()

        #expect(!viewModel.isContentPresented)
        #expect(viewModel.errorMessage == BiometricAuthenticationError.denied.localizedDescription)
        #expect(!viewModel.isAuthenticating)
    }
}

private enum TestStorageError: LocalizedError {
    case failed

    var errorDescription: String? {
        "Test storage failed."
    }
}

private struct StubBiometricAuthenticator: BiometricAuthenticating {
    let result: Result<Void, BiometricAuthenticationError>

    func authenticate() async throws {
        try result.get()
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
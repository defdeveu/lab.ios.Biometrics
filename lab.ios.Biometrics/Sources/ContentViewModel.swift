import Foundation
import Observation

@MainActor
@Observable
final class ContentViewModel {
    private static let fileName = "message.txt"

    var message = "Demo message"
    private(set) var isSaving = false
    private(set) var savedMessage: String?
    private(set) var errorMessage: String?

    @ObservationIgnored private let fileRepository: any FileRepositoryProtocol

    init(fileRepository: any FileRepositoryProtocol) {
        self.fileRepository = fileRepository
    }

    func saveMessage() async {
        guard !isSaving else {
            return
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await fileRepository.save(message: message, to: Self.fileName)
            savedMessage = try await fileRepository.read(from: Self.fileName)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}

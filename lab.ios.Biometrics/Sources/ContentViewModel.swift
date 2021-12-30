import Foundation

class ContentViewModel: ObservableObject {
    private static let fileName = "message.txt"
    @Published var message: String = "Demo message"
    @Published var showError: Bool = false

    private let fileRepository: FileRepositoryProtocol

    init(fileRepository: FileRepositoryProtocol = AppRepository.shared.fileRepository) {
        self.fileRepository = fileRepository
    }

    func saveMessage() {
        if !fileRepository.save(message: message, to: Self.fileName) {
            showError = true
            return
        }

        #if DEBUG
        print(fileRepository.read(from: Self.fileName) ?? "File \(Self.fileName) is empty")
        #endif
    }
}

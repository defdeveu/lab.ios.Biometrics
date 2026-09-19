import SwiftUI

struct ContentView: View {
    @State private var viewModel: ContentViewModel

    @MainActor
    init(viewModel: ContentViewModel = AppRepository.makeContentViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Local message")
                        .font(.title2.bold())
                    Text("Save text in this app's Documents directory.")
                        .foregroundStyle(.secondary)
                }

                TextField("message", text: $viewModel.message)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityLabel("Message")

                Button {
                    Task {
                        await viewModel.saveMessage()
                    }
                } label: {
                    Label(
                        viewModel.isSaving ? "Saving…" : "Save message",
                        systemImage: "square.and.arrow.down"
                    )
                }
                    .buttonStyle(SolidButtonStyle())
                    .disabled(viewModel.isSaving || viewModel.message.isEmpty)

                GroupBox("Last saved value") {
                    Text(viewModel.savedMessage ?? "No message saved yet")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: 640, alignment: .leading)
            .padding(24)
        }
        .navigationTitle("Content")
        .toolbarTitleDisplayMode(.inline)
        .labToolbar()
        .alert(
            "Cannot save the message",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.clearError()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel, action: viewModel.clearError)
        } message: {
            Text(viewModel.errorMessage ?? "Unknown storage error")
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}

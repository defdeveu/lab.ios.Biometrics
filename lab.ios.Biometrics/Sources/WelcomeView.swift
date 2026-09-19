import SwiftUI

struct WelcomeView: View {
    @State private var viewModel: WelcomeViewModel

    @MainActor
    init(viewModel: WelcomeViewModel = AppRepository.makeWelcomeViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome")
                        .font(.largeTitle.bold())
                    Text("Enter the content area and save a message in the app sandbox.")
                        .foregroundStyle(.secondary)
                }

                Button {
                    Task {
                        await viewModel.enterContent()
                    }
                } label: {
                    Label(
                        viewModel.isAuthenticating ? "Authenticating…" : "Enter content",
                        systemImage: "faceid"
                    )
                }
                .buttonStyle(SolidButtonStyle())
                .disabled(viewModel.isAuthenticating)
            }
            .frame(maxWidth: 640, alignment: .leading)
            .padding(24)
        }
        .navigationTitle(AppStrings.appTitle)
        .toolbarTitleDisplayMode(.inline)
        .labToolbar()
        .navigationDestination(isPresented: $viewModel.isContentPresented) {
            ContentView()
        }
        .alert(
            "Authentication failed",
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
            Text(viewModel.errorMessage ?? "Unknown authentication error")
        }
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
}

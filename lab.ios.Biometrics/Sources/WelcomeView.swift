import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome")
                        .font(.largeTitle.bold())
                    Text("Enter the content area and save a message in the app sandbox.")
                        .foregroundStyle(.secondary)
                }

                NavigationLink {
                    ContentView()
                } label: {
                    Label("Enter content", systemImage: "lock.open")
                }
                .buttonStyle(SolidButtonStyle())
            }
            .frame(maxWidth: 640, alignment: .leading)
            .padding(24)
        }
        .navigationTitle(AppStrings.appTitle)
        .toolbarTitleDisplayMode(.inline)
        .labToolbar()
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
}

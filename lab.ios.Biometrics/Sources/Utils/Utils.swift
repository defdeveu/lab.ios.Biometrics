import SwiftUI

struct SolidButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, 16)
            .foregroundStyle(.white)
            .background(.tint, in: RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

private struct LabToolbarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                AppImages.appTitleImage
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundStyle(.primary)
                    .frame(width: 38, height: 38)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension View {
    func labToolbar() -> some View {
        modifier(LabToolbarModifier())
    }
}

enum AppStrings {
    static let appTitle = "Biometrics Lab"
}

enum AppImages {
    static let appTitleImage = Image("logo.ddd.stamp.1905")
}

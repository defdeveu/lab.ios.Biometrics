import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Button { } label: {
                NavigationLink(destination: ContentView()) {
                    Text("Welcome")
                }
            }
            .buttonStyle(SolidButtonStyle())
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { appTitle() }
    }

    @ToolbarContentBuilder
    private func appTitle() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                AppImages.appTitleImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .colorInvert()
                // TODO colorInvert as per the scheme
                Text(AppStrings.appTitle)
                    .font(.title.bold())
                    .foregroundColor(AppColors.navigationForeground)
            }
            .padding(.bottom, 8)
        }
    }
}

#if DEBUG
@available(iOS 15.0, *)
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                Image("AppLogo") // Make sure this image is in your Assets.xcassets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                Image("AppLogo") // Replace with your actual logo asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

                Text("Welcome to PolyWatch")
                    .font(.title)
                    .foregroundColor(.purple)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 252/255, green: 251/255, blue: 250/255))
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

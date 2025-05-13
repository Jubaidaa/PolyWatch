import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @ObservedObject var rootMenuState: MenuState
    
    var body: some View {
        if isActive {
            ContentView(rootMenuState: rootMenuState)
        } else {
            VStack {
                Image("AppLogo") // Replace with your actual logo asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)

                
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

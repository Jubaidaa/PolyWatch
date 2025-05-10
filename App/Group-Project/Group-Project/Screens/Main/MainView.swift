import SwiftUI

struct MainView: View {
    @StateObject private var menuState = MenuState()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            EventsView(isModal: false)
                .tabItem {
                    Label("Events", systemImage: "star.fill")
                }
        }
        .tabViewStyle(.page)
        .environmentObject(menuState)
    }
}

#Preview {
    MainView()
} 
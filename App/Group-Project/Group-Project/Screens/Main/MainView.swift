import SwiftUI

struct MainView: View {
<<<<<<< Updated upstream
=======
    @StateObject private var menuState = MenuState()
    @State private var selectedTab = 0
    
>>>>>>> Stashed changes
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                onLogoTap: { selectedTab = 0 }
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
<<<<<<< Updated upstream
            EventsListView()
                .tabItem {
                    Label("Events", systemImage: "star.fill")
                }
        }
=======
            EventsView(isModal: false,
                onLogoTap: { selectedTab = 0 }
            )
            .tabItem {
                Label("Events", systemImage: "star.fill")
            }
            .tag(1)
        }
        .tabViewStyle(.page)
        .environmentObject(menuState)
        .withGlobalMenu(onLogoTap: { selectedTab = 0 })
>>>>>>> Stashed changes
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
} 
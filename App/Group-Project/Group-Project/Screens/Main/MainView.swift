import SwiftUI

struct MainView: View {
    @ObservedObject var menuState: MenuState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                onLogoTap: { selectedTab = 0 }
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            EventsView(
                isModal: false,
                onLogoTap: {
                    withAnimation {
                        menuState.closeAllOverlays()
                        selectedTab = 0
                    }
                }
            )
            .tabItem {
                Label("Events", systemImage: "star.fill")
            }
            .tag(1)
        }
        .tabViewStyle(.page)
        .environmentObject(menuState)
        .withGlobalMenu(menuState: menuState, onLogoTap: {
            withAnimation {
                menuState.closeAllOverlays()
                selectedTab = 0
            }
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(menuState: MenuState())
    }
}


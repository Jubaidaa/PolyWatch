import SwiftUI

struct GlobalMenuModifier: ViewModifier {
    @StateObject private var menuState = MenuState()
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if menuState.isShowing {
                Rectangle()
                    .fill(Color.black.opacity(0.6))
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            menuState.isShowing = false
                        }
                    }
                    .zIndex(998)
                
                GeometryReader { geometry in
                    HStack {
                        Spacer()
                            .frame(width: 20)
                        
                        SidebarMenuContent()
                            .frame(maxHeight: .infinity, alignment: .top)
                            .padding(.top, geometry.safeAreaInsets.top + 10)
                        
                        Spacer()
                    }
                }
                .zIndex(999)
            }
            
            if menuState.showingCalendar {
                ElectionCalendarView()
                    .zIndex(1000)
            }
            
            if menuState.showingVoterRegistration {
                VoterRegistrationView()
                    .zIndex(1000)
            }
            
            if menuState.showingHelp {
                VoterRegistrationView(showHelpDirectly: true)
                    .zIndex(1000)
            }
            
            if menuState.showingLocalNews {
                LocalNewsView()
                    .zIndex(1000)
            }
            
            if menuState.showingBreakingNews {
                BreakingNewsView()
                    .zIndex(1000)
            }
            
            if menuState.showingEvents {
                EventsView(isModal: true)
                    .zIndex(1000)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: menuState.isShowing)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: menuState.showingCalendar)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: menuState.showingVoterRegistration)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: menuState.showingHelp)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: menuState.showingLocalNews)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: menuState.showingBreakingNews)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: menuState.showingEvents)
        .environmentObject(menuState)
    }
}

// Extension to make it easier to add the menu to any view
extension View {
    func withGlobalMenu() -> some View {
        modifier(GlobalMenuModifier())
    }
} 
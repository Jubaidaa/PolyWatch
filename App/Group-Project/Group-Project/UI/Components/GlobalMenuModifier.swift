import SwiftUI

struct GlobalMenuModifier: ViewModifier {
    // Use the passed MenuState instead of creating a new one
    @ObservedObject var menuState: MenuState
    
    // Add a closure to handle logo tap, defaulting to do nothing
    var onLogoTap: () -> Void = {}
    
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
                        
                        SidebarMenuContent(onLogoTap: {
                            withAnimation {
                                menuState.closeAllOverlays()
                            }
                        })
                            .environmentObject(menuState)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .padding(.top, geometry.safeAreaInsets.top + 10)
                        
                        Spacer()
                    }
                }
                .zIndex(999)
            }
            
            if menuState.showingCalendar {
                Group {
                    #if DEBUG
                    let _ = print("🔍 GlobalMenuModifier: Presenting ElectionCalendarView")
                    let _ = print("   menuState ID: \(menuState.id)")
                    let _ = print("   showingCalendar: \(menuState.showingCalendar)")
                    #endif
                }
                
                ElectionCalendarView(onLogoTap: {
                    withAnimation {
                        menuState.closeAllOverlays()
                    }
                })
                .environmentObject(menuState)
                .zIndex(1000)
            }
            
            if menuState.showingVoterRegistration {
                Group {
                    #if DEBUG
                    let _ = print("🔍 GlobalMenuModifier: Presenting VoterRegistrationView")
                    let _ = print("   menuState ID: \(menuState.id)")
                    let _ = print("   showingVoterRegistration: \(menuState.showingVoterRegistration)")
                    #endif
                }
                
                VoterRegistrationView()
                    .environmentObject(menuState)
                    .zIndex(1000)
            }
            
            if menuState.showingHelp {
                Group {
                    #if DEBUG
                    let _ = print("🔍 GlobalMenuModifier: Presenting HelpView")
                    let _ = print("   menuState ID: \(menuState.id)")
                    let _ = print("   showingHelp: \(menuState.showingHelp)")
                    #endif
                }
                
                HelpSidebarView()
                    .environmentObject(menuState)
                    .zIndex(1000)
            }
            
            if menuState.showingLocalNews {
                LocalNewsView()
                    .environmentObject(menuState)
                    .zIndex(1000)
            }
            
            if menuState.showingBreakingNews {
                BreakingNewsView()
                    .environmentObject(menuState)
                    .zIndex(1000)
            }
            
            if menuState.showingEvents {
                EventsView(isModal: true)
                    .environmentObject(menuState)
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
    }
}

// Extension to make it easier to add the menu to any view
extension View {
    func withGlobalMenu(menuState: MenuState, onLogoTap: @escaping () -> Void = {}) -> some View {
        modifier(GlobalMenuModifier(menuState: menuState, onLogoTap: onLogoTap))
    }
} 

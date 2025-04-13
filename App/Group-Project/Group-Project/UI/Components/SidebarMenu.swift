import SwiftUI

// Global state object to manage menu visibility
class MenuState: ObservableObject {
    @Published var isShowing = false
}

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
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: menuState.isShowing)
        .environmentObject(menuState)
    }
}

// Extension to make it easier to add the menu to any view
extension View {
    func withGlobalMenu() -> some View {
        modifier(GlobalMenuModifier())
    }
}

struct SidebarMenuContent: View {
    @EnvironmentObject private var menuState: MenuState
    @State private var selectedItem: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Menu")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        menuState.isShowing = false
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 28, height: 28)
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            Divider()
                .frame(height: 1)
                .background(Color.white.opacity(0.15))
                .padding(.horizontal, 12)
            
            // Menu Items
            VStack(alignment: .leading, spacing: 2) {
                MenuButton(
                    title: "Upcoming Events",
                    icon: "calendar",
                    isSelected: selectedItem == "events"
                ) {
                    selectedItem = "events"
                    menuState.isShowing = false
                }
                
                MenuButton(
                    title: "Register to Vote",
                    icon: "pencil.circle",
                    isSelected: selectedItem == "register"
                ) {
                    selectedItem = "register"
                    if let url = URL(string: Constants.URLs.registerToVote) {
                        UIApplication.shared.open(url)
                    }
                    menuState.isShowing = false
                }
                
                MenuButton(
                    title: "Local News",
                    icon: "newspaper",
                    isSelected: selectedItem == "local"
                ) {
                    selectedItem = "local"
                    menuState.isShowing = false
                }
                
                MenuButton(
                    title: "Breaking News",
                    icon: "bolt.fill",
                    isSelected: selectedItem == "breaking"
                ) {
                    selectedItem = "breaking"
                    menuState.isShowing = false
                }
            }
            .padding(.vertical, 4)
            
            // Footer
            Text("PolyWatch v1.0")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .padding(.top, 4)
        }
        .frame(width: UIScreen.main.bounds.width * 0.75)
        .frame(maxWidth: 280)
        .background(
            ZStack {
                AppColors.red
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 0)
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon container with standard iOS spacing
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.white.opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.leading, 8)
                
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(height: 44) // Standard iOS list item height
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.white.opacity(0.1))
                            .padding(.horizontal, 4)
                    }
                }
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
} 
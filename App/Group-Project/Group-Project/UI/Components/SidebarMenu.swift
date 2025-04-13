import SwiftUI

struct SidebarMenu: View {
    @Binding var isShowing: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            if isShowing {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShowing = false
                        }
                    }
            }
            
            // Sidebar content
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    Text("Menu")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 60)
                        .padding(.horizontal)
                    
                    Divider()
                        .background(Color.white)
                        .padding(.vertical)
                    
                    // Menu Items
                    VStack(alignment: .leading, spacing: 24) {
                        MenuButton(title: "Upcoming Events", icon: "calendar") {
                            // Action
                        }
                        
                        MenuButton(title: "Register to Vote", icon: "pencil.circle") {
                            if let url = URL(string: Constants.URLs.registerToVote) {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        MenuButton(title: "Local News", icon: "newspaper") {
                            // Action
                        }
                        
                        MenuButton(title: "Breaking News", icon: "bolt.fill") {
                            // Action
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width * 0.7)
                .background(AppColors.red)
                .offset(x: isShowing ? 0 : -UIScreen.main.bounds.width)
                .animation(.easeOut(duration: 0.3), value: isShowing)
                
                Spacer()
            }
        }
        .background(Color.clear)
        .ignoresSafeArea()
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.title3)
                Spacer()
            }
        }
        .foregroundColor(.white)
    }
} 
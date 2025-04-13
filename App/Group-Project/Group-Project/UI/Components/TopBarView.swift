import SwiftUI

struct TopBarView: View {
    let onMenuTap: () -> Void
    let onLogoTap: () -> Void
    let onSearchTap: () -> Void
    @State private var showSidebar = false
    
    var body: some View {
        ZStack {
            // Main content
            HStack {
                // Menu Button
                Button(action: {
                    withAnimation {
                        showSidebar.toggle()
                    }
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: Constants.Dimensions.iconSize))
                        .foregroundColor(AppColors.TopBar.icons)
                        .accessibilityLabel("Menu")
                }
                
                Spacer()
                
                // Center logo
                Button(action: onLogoTap) {
                    Image("sideicon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.6, height: Constants.Dimensions.topBarHeight)
                        .foregroundColor(AppColors.white)
                        .accessibilityLabel("Home")
                }
                
                Spacer()
                
                // Search icon
                Button(action: onSearchTap) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: Constants.Dimensions.iconSize))
                        .foregroundColor(AppColors.TopBar.icons)
                        .accessibilityLabel("Search")
                }
            }
            .padding(.horizontal, Constants.Padding.standard)
            .padding(.vertical, Constants.Padding.vertical)
            .frame(height: Constants.Dimensions.topBarHeight)
            .background(AppColors.TopBar.background)
        }
        .overlay {
            if showSidebar {
                SidebarMenu(isShowing: $showSidebar, onDismiss: {
                    withAnimation {
                        showSidebar = false
                    }
                })
            }
        }
    }
} 
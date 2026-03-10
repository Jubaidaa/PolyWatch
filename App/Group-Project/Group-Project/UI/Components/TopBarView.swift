import SwiftUI

struct TopBarView: View {
    let onMenuTap: () -> Void
    let onLogoTap: () -> Void
    let onSearchTap: () -> Void
    var showBackButton: Bool = false
    var onBackTap: (() -> Void)? = nil
    @EnvironmentObject private var menuState: MenuState
    
    var body: some View {
        ZStack {
            // Main content
            HStack {
                // Back Button or Menu Button
                if showBackButton {
                    Button(action: {
                        onBackTap?()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: Constants.Dimensions.iconSize))
                            .foregroundColor(AppColors.white)
                            .accessibilityLabel("Back")
                    }
                } else {
                    Button(action: {
                        withAnimation {
                            menuState.isShowing = true
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: Constants.Dimensions.iconSize))
                            .foregroundColor(AppColors.TopBar.icons)
                            .accessibilityLabel("Menu")
                    }
                }
                
                Spacer()
                
                // Center logo
                Button(action: {
                    withAnimation {
                        menuState.closeAllOverlays()
                    }
                }) {
                    Image("sideicon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.6, height: Constants.Dimensions.topBarHeight)
                        .foregroundColor(AppColors.white)
                        .accessibilityLabel("Home")
                }
                
                Spacer()
                
                // Profile icon
                Button(action: onSearchTap) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: Constants.Dimensions.iconSize))
                        .foregroundColor(AppColors.TopBar.icons)
                        .accessibilityLabel("Profile")
                }
            }
            .padding(.horizontal, Constants.Padding.standard)
            .padding(.vertical, Constants.Padding.vertical)
            .frame(height: Constants.Dimensions.topBarHeight)
            .background(AppColors.TopBar.background)
        }
    }
} 
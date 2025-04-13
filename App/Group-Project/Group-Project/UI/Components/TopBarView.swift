import SwiftUI

struct TopBarView: View {
    let onMenuTap: () -> Void
    let onLogoTap: () -> Void
    let onSearchTap: () -> Void
    
    var body: some View {
        HStack {
            // Menu Button
            Menu {
                Button("Upcoming Events") {
                    // Action for upcoming events
                }
                Button("Register to Votes") {
                    // Action for register to votes
                }
                Button("Local News") {
                    // Action for local news
                }
                Button("Breaking News") {
                    // Action for breaking news
                }
            } label: {
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
} 
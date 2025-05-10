import SwiftUI

struct HomeView: View {
    @State private var currentIndex = 0
    @EnvironmentObject private var menuState: MenuState
    let onLogoTap: () -> Void
    
    private let carouselItems: [CarouselItem] = [
        CarouselItem(title: "Breaking News: SwiftUI Tips", imageName: "newspaper.fill"),
        CarouselItem(title: "Latest Trends in Tech", imageName: "gear"),
        CarouselItem(title: "Inside PolyWatch Updates", imageName: "info.circle")
    ]
    
    var body: some View {
        ZStack {
            AppColors.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopBarView(
                    onMenuTap: {
                        withAnimation {
                            menuState.isShowing = true
                        }
                    },
                    onLogoTap: onLogoTap,
                    onSearchTap: {}
                )
                
                Spacer()
                
                // MARK: - Carousel
                CarouselView(items: carouselItems, currentIndex: $currentIndex)
                    .padding(.horizontal, Constants.Padding.standard)
                
                Spacer()
                
                // MARK: - Navigation Buttons
                VStack(spacing: Constants.Padding.standard) {
                    NavigationLink(destination: UpcomingView(onLogoTap: onLogoTap)) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.title2)
                            Text("Upcoming Elections")
                                .font(.headline)
                        }
<<<<<<< Updated upstream
                        .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.secondary))
                        
                        NavigationLink(destination: EventsListView()) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.title2)
                                Text("Events")
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.primary))
=======
>>>>>>> Stashed changes
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.secondary))
                    
                    NavigationLink(destination: EventsView(isModal: false, onLogoTap: onLogoTap)) {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.title2)
                            Text("Events")
                                .font(.headline)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.primary))
                }
                .padding(.horizontal, Constants.Padding.large)
                .padding(.bottom, Constants.Padding.bottom)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(onLogoTap: {})
            .environmentObject(MenuState())
    }
} 

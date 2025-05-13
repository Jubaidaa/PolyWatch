import SwiftUI

struct HomeView: View {
    @State private var currentIndex = 0
    @EnvironmentObject private var menuState: MenuState
    let onLogoTap: () -> Void
    
    // Add HomeViewModel to fetch RSS feed data
    @StateObject private var homeViewModel = HomeViewModel()
    
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
                if homeViewModel.isLoading {
                    ProgressView("Loading news...")
                        .frame(height: 400)
                } else {
                    let carouselItems = homeViewModel.getCarouselItems().map { article in
                        CarouselItem(
                            title: article.title,
                            imageName: "newspaper",
                            articleImage: article.image
                        )
                    }
                    CarouselView(items: carouselItems, currentIndex: $currentIndex)
                        .padding(.horizontal, Constants.Padding.standard)
                }
                
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
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.secondary))
                    
                    Button {
                        withAnimation {
                            menuState.showingLocalNews = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "newspaper.fill")
                                .font(.title2)
                                .symbolEffect(.bounce, options: .repeating)
                            Text("Local News")
                                .font(.headline)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.primary))
                    .accessibilityHint("Opens local news feed")
                }
                .padding(.horizontal, Constants.Padding.large)
                .padding(.bottom, Constants.Padding.bottom)
            }
        }
        .task {
            // Fetch RSS feed data when the view appears
            await homeViewModel.fetchCarouselNews()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(onLogoTap: {})
            .environmentObject(MenuState())
    }
}


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
                
                // MARK: - Carousel
                Group {
                    if homeViewModel.isLoading {
                        ProgressView("Loading news...")
                            .frame(height: 220)
                    } else {
                        let carouselItems = homeViewModel.getCarouselItems().map { article in
                            CarouselItem(
                                title: article.title,
                                imageUrl: article.image
                            )
                        }
                        if carouselItems.isEmpty {
                            VStack(spacing: Constants.Padding.standard) {
                                Image(systemName: "newspaper")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppColors.blue)
                                Text("No articles available")
                                    .font(.headline)
                                    .foregroundColor(AppColors.blue)
                            }
                            .frame(height: 220)
                        } else {
                            CarouselView(items: carouselItems, currentIndex: $currentIndex)
                                .frame(width: 300, height: 180)
                                .padding(.horizontal, Constants.Padding.standard)
                        }
                    }
                }
                
                // MARK: - Local News Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Local News")
                        .font(.headline)
                        .padding(.horizontal)

                    let newsToShow = homeViewModel.getBreakingNewsItemsForLocalSection().prefix(3)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(newsToShow.enumerated()), id: \ .element.id) { (index, article) in
                                LocalNewsCard(article: article)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
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
            await homeViewModel.fetchBreakingNewsForLocalSection()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(onLogoTap: {})
            .environmentObject(MenuState())
    }
}


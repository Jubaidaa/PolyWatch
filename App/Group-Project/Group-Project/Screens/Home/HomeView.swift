import SwiftUI

struct HomeView: View {
    @State private var currentIndex = 0
    
    private let carouselItems: [CarouselItem] = [
        CarouselItem(title: "Breaking News: SwiftUI Tips", imageName: "newspaper.fill"),
        CarouselItem(title: "Latest Trends in Tech", imageName: "gear"),
        CarouselItem(title: "Inside PolyWatch Updates", imageName: "info.circle")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    TopBarView(
                        onMenuTap: {},
                        onLogoTap: {},
                        onSearchTap: {}
                    )
                    
                    Spacer()
                    
                    // MARK: - Carousel
                    CarouselView(items: carouselItems, currentIndex: $currentIndex)
                        .padding(.horizontal, Constants.Padding.standard)
                    
                    Spacer()
                    
                    // MARK: - Navigation Buttons
                    VStack(spacing: Constants.Padding.standard) {
                        NavigationLink(destination: UpcomingView()) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.title2)
                                Text("Upcoming Elections")
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.secondary))
                        
                        NavigationLink(destination: EventsView()) {
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 

import SwiftUI
import Foundation

// MARK: - Main ContentView

struct ContentView: View {
    // Single source of truth for menu state
    @ObservedObject var rootMenuState: MenuState
    @State private var selectedTab = 0
    @State private var currentArticleIndex = 0
    @State private var showProfile = false
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    // Add HomeViewModel to fetch RSS feed data
    @StateObject private var homeViewModel = HomeViewModel()
    
    // Fallback articles in case RSS feed fails
    let fallbackArticles = [
        ArticleItem(
            title: "Breaking News: Major Policy Change",
            image: "news1",
            date: "2 hours ago",
            source: "CNN",
            description: "The government announced a major policy change today that will affect millions of citizens across the country. Officials say the new measures are designed to address growing concerns about economic stability.",
            link: URL(string: "https://www.cnn.com")
        ),
        ArticleItem(
            title: "Local Elections Update",
            image: "news2",
            date: "4 hours ago",
            source: "Fox News",
            description: "Local election officials have released updated information about upcoming races and ballot measures. Voters are encouraged to check registration status before the upcoming deadline.",
            link: URL(string: "https://www.foxnews.com")
        ),
        ArticleItem(
            title: "Community Meeting Highlights",
            image: "news3",
            date: "1 day ago",
            source: "ABC News",
            description: "Yesterday's community meeting addressed several key issues facing residents, including infrastructure improvements and public safety concerns. City officials outlined plans for upcoming projects.",
            link: URL(string: "https://www.abcnews.com")
        )
    ]

    @StateObject private var stateManager = EventsStateManager()

    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    TopBarView(
                        onMenuTap: { withAnimation { rootMenuState.isShowing = true } },
                        onLogoTap: {
                            withAnimation {
                                rootMenuState.returnToMainView()
                            }
                        },
                        onSearchTap: {}
                    )
                    .environmentObject(rootMenuState)

                    // Main Content
                    ScrollView {
                        VStack(spacing: 20) {
                            // News Carousel - Now using RSS feed data
                            if homeViewModel.isLoading {
                                ProgressView("Loading news...")
                                    .frame(height: 320)
                            } else {
                                let articlesToShow = !homeViewModel.carouselArticles.isEmpty ? 
                                    homeViewModel.getCarouselItems() : fallbackArticles
                                
                                TabView(selection: $currentArticleIndex) {
                                    ForEach(0..<articlesToShow.count, id: \.self) { index in
                                        NewsCard(article: articlesToShow[index])
                                            .tag(index)
                                    }
                                }
                                .frame(height: 320)
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                            }

                            // New Events Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("New Events")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(sampleEvents) { event in
                                            ActivityCard(event: event)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            // Quick Actions
                            HStack(spacing: 20) {
                                NavigationLink(destination: UpcomingView(onLogoTap: {
                                    withAnimation {
                                        rootMenuState.closeAllOverlays()
                                    }
                                })) {
                                    QuickActionButton(
                                        title: "Upcoming\nElections",
                                        icon: "calendar",
                                        color: Color(red: 0.2, green: 0.5, blue: 0.8)
                                    )
                                }

                                NavigationLink(destination: EventsView(isModal: false)) {
                                    QuickActionButton(
                                        title: "Events",
                                        icon: "calendar.badge.clock",
                                        color: Color(red: 0.8, green: 0.3, blue: 0.3)
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }

                    Spacer()
                }

                // Dimmed overlay & sidebar
                if rootMenuState.isShowing {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { rootMenuState.isShowing = false } }
                        .zIndex(1)

                    VStack {
                        SidebarMenuContent(onLogoTap: {
                            withAnimation {
                                rootMenuState.closeAllOverlays()
                            }
                        })
                        .environmentObject(rootMenuState)
                        .frame(maxWidth: 320)
                        .padding(.top, 60)
                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                    .zIndex(2)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showProfile) {
                UserProfileView()
            }
            .fullScreenCover(isPresented: $rootMenuState.showingHelp) {
                VoterRegistrationView()
                    .environmentObject(rootMenuState)
            }
            .fullScreenCover(isPresented: $rootMenuState.showingVoterRegistration) {
                VoterRegistrationView()
                    .environmentObject(rootMenuState)
            }
            .fullScreenCover(isPresented: $rootMenuState.showingEvents) {
                EventsView(isModal: true)
                .environmentObject(rootMenuState)
            }
            .fullScreenCover(isPresented: $rootMenuState.showingCalendar) {
                ElectionCalendarView(onLogoTap: {
                    withAnimation {
                        rootMenuState.closeAllOverlays()
                    }
                })
                .environmentObject(rootMenuState)
            }
            .fullScreenCover(isPresented: $rootMenuState.showingLocalNews) {
                LocalNewsView()
                    .environmentObject(rootMenuState)
            }
            .fullScreenCover(isPresented: $rootMenuState.showingBreakingNews) {
                BreakingNewsView()
                    .environmentObject(rootMenuState)
            }
            .task {
                // Fetch RSS feed data when the view appears
                await homeViewModel.fetchCarouselNews()
            }
        }
    }
}

// MARK: - Supporting Views

struct NewsCard: View {
    let article: ArticleItem
    @State private var showArticleDetail = false

    var body: some View {
        Button(action: {
            showArticleDetail = true
        }) {
            ZStack(alignment: .bottomLeading) {
                // Use URL or asset image
                Group {
                    if article.image.hasPrefix("http") {
                        AsyncImage(url: URL(string: article.image)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "newspaper")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Image(article.image.contains("/") ? "news1" : article.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            @unknown default:
                                Image(article.image.contains("/") ? "news1" : article.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                        .transition(.opacity)
                    } else {
                        Image(article.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .clipped()

                // Improved gradient for better text readability
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .black.opacity(0.3),
                        .black.opacity(0.7),
                        .black.opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 4)

                    HStack(spacing: 4) {
                        Text(article.source)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text(article.date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding()
            }
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showArticleDetail) {
            ArticleDetailView(article: article)
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(color)
        .cornerRadius(12)
    }
}

private let sampleEvents: [Event] = [
    Event(title: "Community Town Hall Meeting", date: Date(), endDate: nil, location: "123 Main St", description: "A community meeting.", imageURL: nil, price: nil, registrationRequired: true, registrationURL: nil, organizer: "City Council", tags: ["Community"], status: .upcoming, state: nil),
    Event(title: "Voter Registration Drive", date: Date().addingTimeInterval(86400), endDate: nil, location: "Library Plaza", description: "Register to vote!", imageURL: nil, price: nil, registrationRequired: false, registrationURL: nil, organizer: "Volunteers", tags: ["Voter"], status: .upcoming, state: nil),
    Event(title: "School Board Q&A", date: Date().addingTimeInterval(172800), endDate: nil, location: "High School Gym", description: "Q&A with the school board.", imageURL: nil, price: nil, registrationRequired: false, registrationURL: nil, organizer: "School Board", tags: ["Education"], status: .upcoming, state: nil)
]

struct ActivityCard: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 32, height: 32)
                    if
                        let imageURL = event.imageURL,
                        let url = URL(string: imageURL)
                    {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.clear
                        }
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                    }
                }
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(width: 140)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(rootMenuState: MenuState())
    }
}


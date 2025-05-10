import SwiftUI

// MARK: - Model for Carousel Articles
struct ArticleItem: Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let date: String
    let source: String
}

struct ContentView: View {
    @EnvironmentObject private var menuState: MenuState
    @State private var selectedTab = 0
    @State private var currentArticleIndex = 0
    @State private var showProfile = false
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    let articles = [
        ArticleItem(title: "Breaking News: Major Policy Change", image: "news1", date: "2 hours ago", source: "CNN"),
        ArticleItem(title: "Local Elections Update", image: "news2", date: "4 hours ago", source: "Fox News"),
        ArticleItem(title: "Community Meeting Highlights", image: "news3", date: "1 day ago", source: "ABC News")
    ]
    
    var body: some View {
        let menuWidth: CGFloat = 320
        NavigationView {
            ZStack(alignment: .leading) {
                Color(.systemBackground)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    TopBarView(
                        onMenuTap: {
                            withAnimation {
                                menuState.isShowing = true
                            }
                        },
                        onLogoTap: {},
                        onSearchTap: {}
                    )
                    
                    // Main Content
                    ScrollView {
                        VStack(spacing: 20) {
                            // News Carousel
                            TabView(selection: $currentArticleIndex) {
                                ForEach(0..<articles.count, id: \.self) { index in
                                    NewsCard(article: articles[index])
                                        .tag(index)
                                }
                            }
                            .frame(height: 320)
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                            .onReceive(timer) { _ in
                                withAnimation {
                                    currentArticleIndex = (currentArticleIndex + 1) % articles.count
                                }
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
                            // Quick Actions (moved below New Events)
                            HStack(spacing: 20) {
                                NavigationLink(destination: UpcomingView()) {
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
<<<<<<< Updated upstream
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 400)
                    
                    Spacer()
                    
                    // MARK: - Two Buttons (American flag colors)
                    VStack(spacing: 16) {
                        NavigationLink(destination: UpcomingView()) {
                            Text("Upcoming Elections")
                                .font(.headline)
                                .foregroundColor(whiteColor)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(blueColor)
                                .cornerRadius(8)
                        }
                        
                        NavigationLink(destination: EventsView()) {
                            Text("Events")
                                .font(.headline)
                                .foregroundColor(whiteColor)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(redColor)
                                .cornerRadius(8)
=======
                }
                if menuState.isShowing {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                menuState.isShowing = false
                            }
>>>>>>> Stashed changes
                        }
                        .zIndex(1)
                }
                if menuState.isShowing {
                    VStack {
                        SidebarMenuContent()
                            .environmentObject(menuState)
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
            // Hamburger menu navigation
            .fullScreenCover(isPresented: $menuState.showingHelp, onDismiss: { menuState.showingHelp = false }) {
                VoterRegistrationView(showHelpDirectly: true)
                    .environmentObject(menuState)
            }
            .fullScreenCover(isPresented: $menuState.showingEvents, onDismiss: { menuState.showingEvents = false }) {
                EventsView(isModal: true)
                    .environmentObject(menuState)
            }
            .fullScreenCover(isPresented: $menuState.showingCalendar, onDismiss: { menuState.showingCalendar = false }) {
                ElectionCalendarView()
                    .environmentObject(menuState)
            }
            .fullScreenCover(isPresented: $menuState.showingLocalNews, onDismiss: { menuState.showingLocalNews = false }) {
                LocalNewsView()
                    .environmentObject(menuState)
            }
            .fullScreenCover(isPresented: $menuState.showingBreakingNews, onDismiss: { menuState.showingBreakingNews = false }) {
                BreakingNewsView()
                    .environmentObject(menuState)
            }
        }
    }
}

<<<<<<< Updated upstream
//
// Dummy views for navigation links – replace with your actual views
//

struct EventsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AppColors.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopBarView(
                    onMenuTap: {},
                    onLogoTap: { presentationMode.wrappedValue.dismiss() },
                    onSearchTap: {}
                )
                
                Spacer()
                
                Text("Events")
                    .font(.title)
                    .padding()
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
=======
struct NewsCard: View {
    let article: ArticleItem
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(article.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack {
                    Text(article.source)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(article.date)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
        }
        .cornerRadius(12)
        .padding(.horizontal)
>>>>>>> Stashed changes
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
    Event(title: "Voter Registration Drive", date: Date().addingTimeInterval(3600 * 24), endDate: nil, location: "Library Plaza", description: "Register to vote!", imageURL: nil, price: nil, registrationRequired: false, registrationURL: nil, organizer: "Volunteers", tags: ["Voter"], status: .upcoming, state: nil),
    Event(title: "School Board Q&A", date: Date().addingTimeInterval(3600 * 48), endDate: nil, location: "High School Gym", description: "Q&A with the school board.", imageURL: nil, price: nil, registrationRequired: false, registrationURL: nil, organizer: "School Board", tags: ["Education"], status: .upcoming, state: nil)
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
                    if let imageURL = event.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
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

#Preview {
    ContentView()
}

import SwiftUI

// MARK: - Model for Carousel Articles
struct ArticleItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
}

struct ContentView: View {
    // Example data for the carousel articles
    private let articles: [ArticleItem] = [
        ArticleItem(title: "Breaking News: SwiftUI Tips", imageName: "news1"),
        ArticleItem(title: "Latest Trends in Tech", imageName: "news2"),
        ArticleItem(title: "Inside PolyWatch Updates", imageName: "news3")
    ]
    
    // Carousel state
    @State private var currentIndex = 0
    
    // Auto-scroll timer (4.5 seconds)
    let carouselTimer = Timer.publish(every: 4.5, on: .main, in: .common)
        .autoconnect()
    
    // American flag colors (RGB values)
    let redColor = Color(red: 178/255, green: 34/255, blue: 52/255)    // #B22234
    let blueColor = Color(red: 60/255, green: 59/255, blue: 110/255)     // #3C3B6E
    let whiteColor = Color.white

    var body: some View {
        ZStack {
            // Overall Background: White (flag background)
            whiteColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Bar (Red)
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
                            .font(.system(size: 28))
                            .foregroundColor(whiteColor)
                    }
                    
                    Spacer()
                    
                    // Center logo
                    Image("sideicon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 80)
                    
                    Spacer()
                    
                    // Right magnifying glass icon
                    Button {
                        // Search action
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 28))
                            .foregroundColor(whiteColor)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .frame(height: 100) // Back to previous height
                .background(redColor)
                
                Spacer()
                
                // MARK: - Bigger Blue Carousel Box
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(blueColor)
                    
                    if !articles.isEmpty {
                        TabView(selection: $currentIndex) {
                            ForEach(articles.indices, id: \.self) { index in
                                VStack(spacing: 12) {
                                    Image(articles[index].imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 180)
                                        .cornerRadius(8)
                                    
                                    Text(articles[index].title)
                                        .font(.title3)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(whiteColor)
                                        .padding(.horizontal, 16)
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .onReceive(carouselTimer) { _ in
                            withAnimation(.easeInOut) {
                                currentIndex = (currentIndex + 1) % articles.count
                            }
                        }
                        .padding(24)
                    } else {
                        Text("No articles available")
                            .foregroundColor(whiteColor)
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.9, height: 400) // Bigger box
                
                Spacer()
                
                // MARK: - Two Buttons (American flag colors)
                VStack(spacing: 16) {
                    NavigationLink(destination: UpcomingElectionsView()) {
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
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

//
// Dummy views for navigation links – replace with your actual views
//

struct UpcomingElectionsView: View {
    var body: some View {
        VStack {
            Text("Upcoming Elections")
                .font(.title)
                .padding()
        }
        .navigationTitle("Upcoming Elections")
    }
}

struct EventsView: View {
    var body: some View {
        VStack {
            Text("Events")
                .font(.title)
                .padding()
        }
        .navigationTitle("Events")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

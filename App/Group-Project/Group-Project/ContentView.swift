import SwiftUI

// Model for the carousel articles
struct ArticleItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
}

struct ContentView: View {
    
    @State private var currentIndex = 0
    // Timer fires every 4.5 seconds for automatic slide transition
    let carouselTimer = Timer.publish(every: 4.5, on: .main, in: .common)
        .autoconnect()
    
    // Example data – ensure these images ("news1", "news2", "news3", "sideicon") are in your Assets
    let articles = [
        ArticleItem(title: "Breaking News: SwiftUI Tips", imageName: "news1"),
        ArticleItem(title: "Latest Trends in Tech", imageName: "news2"),
        ArticleItem(title: "Inside PolyWatch Updates", imageName: "news3")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                // Top Bar with side icon and app name
                HStack {
                    // Tap on the icon can trigger a menu or a new screen if needed
                    Button {
                        // Add any action if necessary
                    } label: {
                        Image("sideicon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    Text("PolyWatch")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Placeholder for a search or profile button
                    Button {
                        // Add your action here
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.headline)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Carousel displaying article images and titles; auto-scrolls every 4.5 seconds
                ZStack {
                    if !articles.isEmpty {
                        TabView(selection: $currentIndex) {
                            ForEach(articles.indices, id: \.self) { index in
                                VStack(spacing: 8) {
                                    Image(articles[index].imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .cornerRadius(8)
                                    
                                    Text(articles[index].title)
                                        .font(.headline)
                                        .foregroundColor(.purple)
                                }
                                .tag(index)
                                .padding()
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(height: 280)
                        .onReceive(carouselTimer) { _ in
                            withAnimation(.easeInOut) {
                                currentIndex = (currentIndex + 1) % articles.count
                            }
                        }
                    } else {
                        Text("No articles available")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 20)
                
                // Buttons for Upcoming Elections and Events
                HStack(spacing: 20) {
                    NavigationLink(destination: UpcomingElectionsView()) {
                        Text("Upcoming Elections")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: EventsView()) {
                        Text("Events")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                Spacer()
            }
            // Using your off-white background: #FCFBFA (RGB: 252, 251, 250)
            .background(Color(red: 252/255, green: 251/255, blue: 250/255))
            .ignoresSafeArea()
        }
    }
}

// Dummy view for Upcoming Elections – adjust as needed
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

// Dummy view for Events – adjust as needed
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

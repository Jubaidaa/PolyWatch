import SwiftUI

// MARK: - Model for Carousel Articles
struct ArticleItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
}

struct ContentView: View {
    // Example data for the carousel
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
    
    var body: some View {
        ZStack {
            // Background color (#FCFBFA)
            Color(red: 252/255, green: 251/255, blue: 250/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Red Top Bar
                HStack {
                    // Left icon (tap action optional)
                    Button {
                        // e.g., show side menu
                    } label: {
                        Image(systemName: "sidebar.left") // Replace with your own icon
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    
                    Spacer()
                    
                    // App Name in Center
                    Text("PolyWatch")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Right icon (search or profile), optional
                    Button {
                        // e.g., search action
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.trailing)
                    }
                }
                .frame(height: 60)
                .background(Color.red)
                
                Spacer()
                
                // MARK: - Blue Box (Carousel)
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue)
                    
                    // The contents of the box: sliding article images & titles
                    if !articles.isEmpty {
                        TabView(selection: $currentIndex) {
                            ForEach(articles.indices, id: \.self) { index in
                                VStack(spacing: 8) {
                                    Image(articles[index].imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 120)
                                    
                                    Text(articles[index].title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .multilineTextAlignment(.center)
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .onReceive(carouselTimer) { _ in
                            withAnimation(.easeInOut) {
                                currentIndex = (currentIndex + 1) % articles.count
                            }
                        }
                        .padding(16)
                    } else {
                        Text("No articles available")
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 300, height: 350)
                
                Spacer()
                
                // MARK: - Two Green Buttons
                VStack(spacing: 16) {
                    Button {
                        // Upcoming Elections action
                    } label: {
                        Text("Upcoming Elections")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    
                    Button {
                        // Events action
                    } label: {
                        Text("Events")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

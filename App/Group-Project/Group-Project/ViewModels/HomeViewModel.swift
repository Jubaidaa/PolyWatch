import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var carouselArticles: [RSSItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let rssService = RSSService()
    private let bbcWorldNewsFeed = "https://feeds.bbci.co.uk/news/world/rss.xml"
    
    init() {
        // Initialize with empty data
    }
    
    func fetchCarouselNews() async {
        isLoading = true
        error = nil
        
        do {
            try await rssService.fetchRSS(from: bbcWorldNewsFeed)
            
            // Get up to 5 articles for the carousel
            let articles = rssService.items.prefix(5).map { $0 }
            
            withAnimation {
                self.carouselArticles = articles
                self.isLoading = false
            }
            
            print("Fetched \(articles.count) BBC news articles for carousel")
        } catch {
            self.error = error
            self.isLoading = false
            print("Error fetching BBC news: \(error)")
        }
    }
    
    // Convert RSSItems to ArticleItems for the carousel
    func getCarouselItems() -> [ArticleItem] {
        return carouselArticles.map { item in
            ArticleItem(
                title: item.title,
                image: item.imageUrl?.absoluteString ?? "news1", // Fallback to default image
                date: formatDate(item.pubDate),
                source: item.source
            )
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else {
            return "Recently"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
} 
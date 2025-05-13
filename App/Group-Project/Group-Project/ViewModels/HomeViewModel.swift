import SwiftUI
import Combine

// Import RSSItem type
@_exported import struct Foundation.URL
import FeedKit

@MainActor
class HomeViewModel: ObservableObject {
    @Published var carouselArticles: [RSSItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let rssService = RSSService()
    private let bbcWorldNewsFeed = "https://feeds.bbci.co.uk/news/world/rss.xml"
    private let newsState = NewsState.shared
    
    init() {
        // Initialize with empty data
    }
    
    func fetchCarouselNews() async {
        isLoading = true
        error = nil
        
        do {
            try await rssService.fetchRSS(from: bbcWorldNewsFeed)
            
            // Filter articles to only include those with valid images
            let articlesWithImages = rssService.items.filter { item in
                if let imageUrl = item.imageUrl?.absoluteString {
                    // Check if the URL is valid and not empty
                    return !imageUrl.isEmpty && URL(string: imageUrl) != nil
                }
                return false
            }
            
            // Get up to 5 articles with images for the carousel
            let articles = articlesWithImages.prefix(5).map { $0 }
            
            withAnimation {
                self.carouselArticles = articles
                self.isLoading = false
            }
            
            print("Fetched \(articles.count) BBC news articles with images for carousel")
        } catch {
            self.error = error
            self.isLoading = false
            print("Error fetching BBC news: \(error)")
        }
    }
    
    // Convert RSSItems to ArticleItems for the carousel
    func getCarouselItems() -> [ArticleItem] {
        // Combine breaking news and local news articles
        let allArticles = newsState.getArticlesWithImages()
        
        // If we have breaking news articles, use those first
        if !allArticles.isEmpty {
            return allArticles.prefix(5).map { item in
                ArticleItem(
                    title: item.title,
                    image: item.imageUrl?.absoluteString ?? "",
                    date: formatDate(item.pubDate),
                    source: item.source,
                    description: item.description,
                    link: item.link
                )
            }
        }
        
        // Fallback to carousel articles if no breaking news
        return carouselArticles.map { item in
            ArticleItem(
                title: item.title,
                image: item.imageUrl?.absoluteString ?? "",
                date: formatDate(item.pubDate),
                source: item.source,
                description: item.description,
                link: item.link
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
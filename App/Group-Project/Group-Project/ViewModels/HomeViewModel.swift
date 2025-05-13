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
    
    // Breaking news feeds for the home view
    let breakingNewsFeeds = [
        "Progressive": "https://progressive.org/magazine/rss-feeds/",
        "OpEdNews": "https://www.opednews.com/feeds/rss.xml",
        "Al Jazeera": "https://www.aljazeera.com/xml/rss/all.xml",
        "France24": "https://www.france24.com/en/rss",
        "GlobalIssues": "https://www.globalissues.org/news/feed"
    ]
    
    // Fetch breaking news for home
    func fetchCarouselNews() async {
        isLoading = true
        error = nil
        var allArticles: [RSSItem] = []
        
        await withTaskGroup(of: [RSSItem]?.self) { group in
            for (_, feed) in breakingNewsFeeds {
                group.addTask {
                    let service = RSSService()
                    do {
                        try await service.fetchRSS(from: feed)
                        // Filter for articles with images
                        return service.items.filter { item in
                            if let imageUrl = item.imageUrl?.absoluteString {
                                return !imageUrl.isEmpty && URL(string: imageUrl) != nil
                            }
                            return false
                        }
                    } catch {
                        print("Error fetching feed: \(error)")
                        return nil
                    }
                }
            }
            for await result in group {
                if let items = result {
                    allArticles.append(contentsOf: items)
                }
            }
        }
        // Limit to 5 articles for the carousel
        let limitedArticles = allArticles.prefix(5)
        withAnimation {
            self.carouselArticles = Array(limitedArticles)
            self.isLoading = false
        }
        print("Fetched \(self.carouselArticles.count) breaking news articles with images for carousel")
    }
    
    // Convert RSSItems to ArticleItems for the carousel
    func getCarouselItems() -> [ArticleItem] {
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
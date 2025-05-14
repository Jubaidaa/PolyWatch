import SwiftUI
import Combine
import FeedKit

@MainActor
class BreakingNewsPreviewViewModel: ObservableObject {
    @Published var breakingNewsArticles: [RSSItem] = []
    @Published var isLoading = false
    @Published var error: Error?

    let breakingNewsFeeds = [
        "Progressive": "https://progressive.org/magazine/rss-feeds/",
        "OpEdNews": "https://www.opednews.com/feeds/rss.xml",
        "Al Jazeera": "https://www.aljazeera.com/xml/rss/all.xml",
        "France24": "https://www.france24.com/en/rss",
        "GlobalIssues": "https://www.globalissues.org/news/feed"
    ]

    func fetchBreakingNews() async {
        isLoading = true
        error = nil
        var articlesBySource: [String: [RSSItem]] = [:]

        await withTaskGroup(of: (String, [RSSItem])?.self) { group in
            for (source, feed) in breakingNewsFeeds {
                group.addTask {
                    let service = RSSService()
                    do {
                        try await service.fetchRSS(from: feed)
                        // Filter for articles with images
                        let articlesWithImages = service.items.filter { item in
                            if let imageUrl = item.imageUrl?.absoluteString {
                                return !imageUrl.isEmpty && URL(string: imageUrl) != nil
                            }
                            return false
                        }
                        // Create new items with the correct source instead of modifying existing ones
                        let articlesWithSource = articlesWithImages.map { item in
                            RSSItem(
                                title: item.title,
                                link: item.link,
                                pubDate: item.pubDate,
                                description: item.description,
                                imageUrl: item.imageUrl,
                                source: source
                            )
                        }
                        return (source, articlesWithSource)
                    } catch {
                        print("Error fetching feed: \(error)")
                        return nil
                    }
                }
            }
            for await result in group {
                if let (source, items) = result, !items.isEmpty {
                    articlesBySource[source] = items
                }
            }
        }
        
        // Ensure at least one article from each source
        var selectedArticles: [RSSItem] = []
        for (_, articles) in articlesBySource {
            if !articles.isEmpty {
                selectedArticles.append(articles[0])
                }
            }
        
        // If we need more articles to reach our limit, add additional ones
        if selectedArticles.count < 10 {
            var additionalArticles: [RSSItem] = []
            for (_, articles) in articlesBySource {
                if articles.count > 1 {
                    additionalArticles.append(contentsOf: articles.dropFirst())
                }
            }
            // Shuffle additional articles for variety
            additionalArticles.shuffle()
            selectedArticles.append(contentsOf: additionalArticles.prefix(10 - selectedArticles.count))
        }
        
        self.breakingNewsArticles = selectedArticles
        isLoading = false
        print("Fetched \(self.breakingNewsArticles.count) breaking news articles with images for local news section")
    }

    func getBreakingNewsItems() -> [ArticleItem] {
        return breakingNewsArticles.map { item in
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
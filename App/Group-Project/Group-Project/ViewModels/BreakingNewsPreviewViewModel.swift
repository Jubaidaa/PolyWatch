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
        // Limit to 10 articles for the local news section
        let limitedArticles = allArticles.prefix(10)
        self.breakingNewsArticles = Array(limitedArticles)
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
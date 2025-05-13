import SwiftUI
import Combine

@MainActor
class BreakingNewsViewModel: ObservableObject {
    @Published var currentArticles: [RSSItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let newsState = NewsState.shared

    // Breaking news feeds
    let breakingNewsFeeds = [
        "Progressive": "https://progressive.org/magazine/rss-feeds/",
        "OpEdNews": "https://www.opednews.com/feeds/rss.xml",
        "Al Jazeera": "https://www.aljazeera.com/xml/rss/all.xml",
        "France24": "https://www.france24.com/en/rss",
        "GlobalIssues": "https://www.globalissues.org/news/feed"
    ]

    private let articlesPerSource = 2
    private var rotationTimer: Timer?
    private var articlesBySource: [String: [RSSItem]] = [:]
    private var currentIndexBySource: [String: Int] = [:]

    init() {
        // nothing here; call fetchBreakingNews() onAppear
    }

    deinit {
        rotationTimer?.invalidate()
    }

    private func setupRotationTimer() {
        if !articlesBySource.isEmpty {
            rotationTimer?.invalidate()
            rotationTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.rotateToNextArticles()
                }
            }
            rotateToNextArticles()
        }
    }

    private func rotateToNextArticles() {
        var nextArticles: [RSSItem] = []
        let sourcesWithArticles = articlesBySource.filter { !$0.value.isEmpty }
        
        // First, try to include one article from each source that has articles
        for (source, articles) in sourcesWithArticles {
            guard !articles.isEmpty else { continue }
            let currentIndex = currentIndexBySource[source] ?? 0
            let index = currentIndex % articles.count
            nextArticles.append(articles[index])
            
            // Update index for this source
            let newIndex = (currentIndex + 1) % max(1, articles.count)
            currentIndexBySource[source] = newIndex
        }
        
        // If we have space for more articles, add additional ones
        let maxArticlesToShow = min(10, sourcesWithArticles.values.reduce(0) { $0 + $1.count })
        if nextArticles.count < maxArticlesToShow {
            var additionalArticles: [RSSItem] = []
            for (source, articles) in sourcesWithArticles {
                if articles.count > 1 {
                    let startIndex = (currentIndexBySource[source] ?? 0) + 1
                    for offset in 0..<min(2, articles.count - 1) {
                        let index = (startIndex + offset) % articles.count
                        additionalArticles.append(articles[index])
                    }
                }
            }
            // Shuffle additional articles for variety
            additionalArticles.shuffle()
            nextArticles.append(contentsOf: additionalArticles.prefix(maxArticlesToShow - nextArticles.count))
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            currentArticles = nextArticles
            // Update shared state with all breaking news articles
            newsState.updateBreakingNews(articlesBySource.values.flatMap { $0 })
        }
    }

    func fetchBreakingNews() async {
        isLoading = true
        articlesBySource.removeAll()
        currentIndexBySource.removeAll()
        currentArticles.removeAll()

        await withTaskGroup(of: (String, [RSSItem])?.self) { group in
            for (source, feed) in breakingNewsFeeds {
                group.addTask {
                    let service = RSSService()
                    do {
                        try await service.fetchRSS(from: feed)
                        // Filter articles to only include those with valid images
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
                        print("Error fetching \(source) feed: \(error)")
                        return nil
                    }
                }
            }
            for await result in group {
                if let (source, items) = result {
                    articlesBySource[source] = items
                    currentIndexBySource[source] = 0
                }
            }
        }
        
        // Ensure at least one article from each source is shown initially
        var initialArticles: [RSSItem] = []
        for (_, articles) in articlesBySource {
            if !articles.isEmpty {
                initialArticles.append(articles[0])
            }
        }
        
        // If we have space for more articles, add them
        let remainingSlots = max(0, 10 - initialArticles.count)
        if remainingSlots > 0 {
            var additionalArticles: [RSSItem] = []
            for (_, articles) in articlesBySource {
                if articles.count > 1 {
                    additionalArticles.append(contentsOf: articles.dropFirst().prefix(1))
                }
            }
            initialArticles.append(contentsOf: additionalArticles.prefix(remainingSlots))
        }
        
        // Update current articles
        withAnimation {
            currentArticles = initialArticles
            // Update shared state with all breaking news articles
            newsState.updateBreakingNews(articlesBySource.values.flatMap { $0 })
        }
        
        setupRotationTimer()
        isLoading = false
    }
} 

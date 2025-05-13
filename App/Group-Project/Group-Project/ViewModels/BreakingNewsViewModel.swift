import SwiftUI
import Combine

@MainActor
class BreakingNewsViewModel: ObservableObject {
    @Published var currentArticles: [RSSItem] = []
    @Published var isLoading = false
    @Published var error: Error?

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
        for (source, articles) in articlesBySource {
            guard !articles.isEmpty else { continue }
            let currentIndex = currentIndexBySource[source] ?? 0
            for offset in 0..<articlesPerSource {
                let index = (currentIndex + offset) % articles.count
                if index < articles.count {
                    nextArticles.append(articles[index])
                }
            }
            let newIndex = (currentIndex + articlesPerSource) % max(1, articles.count)
            currentIndexBySource[source] = newIndex
        }
        withAnimation(.easeInOut(duration: 0.5)) {
            currentArticles = nextArticles
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
                        return (source, service.items)
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
        setupRotationTimer()
        isLoading = false
    }
} 
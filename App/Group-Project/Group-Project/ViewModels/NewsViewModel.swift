import SwiftUI
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    @Published private var rssService = RSSService()
    @Published var currentArticles: [RSSItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    let localNewsFeeds = [
        "Mission Local": "https://missionlocal.org/feed/",
        "East Bay Express": "https://eastbayexpress.com/feed/",
        "IndyBay": "https://www.indybay.org/newsitems.rdf",
        "SF Public Press": "https://www.sfpublicpress.org/feed"
    ]
    
    private var rotationTimer: Timer?
    private var articlesBySource: [String: [RSSItem]] = [:]
    private var currentIndexBySource: [String: Int] = [:]
    
    init() {
        setupRotationTimer()
    }
    
    deinit {
        rotationTimer?.invalidate()
    }
    
    private func setupRotationTimer() {
        // Only setup timer if we have articles
        if !articlesBySource.isEmpty {
            rotationTimer?.invalidate() // Clear any existing timer
            rotationTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.rotateToNextArticles()
                }
            }
            // Show first set of articles immediately
            rotateToNextArticles()
        }
    }
    
    private func rotateToNextArticles() {
        var nextArticles: [RSSItem] = []
        
        // Get one article from each source
        for (source, articles) in articlesBySource {
            guard !articles.isEmpty else { continue }
            
            let currentIndex = currentIndexBySource[source] ?? 0
            nextArticles.append(articles[currentIndex])
            
            // Update index for this source
            currentIndexBySource[source] = (currentIndex + 1) % articles.count
        }
        
        // Update displayed articles with animation
        withAnimation(.easeInOut(duration: 0.5)) {
            currentArticles = nextArticles
        }
    }
    
    func fetchLocalNews() async {
        isLoading = true
        articlesBySource.removeAll()
        currentIndexBySource.removeAll()
        currentArticles.removeAll()
        
        // Fetch from all sources concurrently
        await withTaskGroup(of: (String, [RSSItem])?.self) { group in
            for (source, feed) in localNewsFeeds {
                group.addTask {
                    let service = RSSService()
                    await service.fetchRSS(from: feed)
                    return (source, service.items)
                }
            }
            
            // Collect results
            for await result in group {
                if let (source, items) = result {
                    print("Fetched \(items.count) items from \(source)") // Debug info
                    articlesBySource[source] = items
                    currentIndexBySource[source] = 0
                }
            }
        }
        
        // Setup timer and show first set of articles
        setupRotationTimer()
        isLoading = false
        
        // Debug info
        let totalArticles = articlesBySource.values.map { $0.count }.reduce(0, +)
        print("Total articles fetched: \(totalArticles)")
    }
    
    func fetchBreakingNews() async {
        isLoading = true
        currentArticles.removeAll()
        isLoading = false
    }
} 
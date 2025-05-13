import SwiftUI

@MainActor
class NewsState: ObservableObject {
    @Published var breakingNewsArticles: [RSSItem] = []
    @Published var localNewsArticles: [RSSItem] = []
    
    // Singleton instance
    static let shared = NewsState()
    
    private init() {}
    
    func updateBreakingNews(_ articles: [RSSItem]) {
        breakingNewsArticles = articles
    }
    
    func updateLocalNews(_ articles: [RSSItem]) {
        localNewsArticles = articles
    }
    
    func getArticlesWithImages() -> [RSSItem] {
        return (breakingNewsArticles + localNewsArticles).filter { item in
            if let imageUrl = item.imageUrl?.absoluteString {
                return !imageUrl.isEmpty && URL(string: imageUrl) != nil
            }
            return false
        }
    }
} 
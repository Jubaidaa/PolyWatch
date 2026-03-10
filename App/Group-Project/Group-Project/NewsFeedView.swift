import SwiftUI
import Foundation

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let source: String
    let date: Date
    let summary: String?
}

enum FeedError: Error {
    case invalidURL
    case networkError
    case parsingError
    case emptyFeed
    
    var description: String {
        switch self {
        case .invalidURL: return "Invalid URL provided"
        case .networkError: return "Network connection failed"
        case .parsingError: return "Failed to parse feed"
        case .emptyFeed: return "Feed contains no items"
        }
    }
}

class RSSAggregator: ObservableObject {
    @Published var isLoading = false
    @Published var error: FeedError?
    
    let feeds = [
        ("https://truthout.org/feed/", "Truthout"),
        ("https://www.thestranger.com/feeds/rss", "The Stranger"),
        ("https://www.truthdig.com/feed/", "Truthdig")
    ]
    
    // Make these methods internal or public so they can be accessed by subclasses
    func extractTitle(from xmlString: String) -> String? {
        if let range = xmlString.range(of: "<title>") {
            let start = range.upperBound
            if let end = xmlString.range(of: "</title>", range: start..<xmlString.endIndex) {
                return String(xmlString[start..<end.lowerBound])
            }
        }
        return nil
    }
    
    func extractLink(from xmlString: String) -> String? {
        if let range = xmlString.range(of: "<link>") {
            let start = range.upperBound
            if let end = xmlString.range(of: "</link>", range: start..<xmlString.endIndex) {
                return String(xmlString[start..<end.lowerBound])
            }
        }
        return nil
    }
    
    func extractDescription(from xmlString: String) -> String? {
        if let range = xmlString.range(of: "<description>") {
            let start = range.upperBound
            if let end = xmlString.range(of: "</description>", range: start..<xmlString.endIndex) {
                return String(xmlString[start..<end.lowerBound])
            }
        }
        return nil
    }
    
    func fetchAllArticles(completion: @escaping (Result<[Article], FeedError>) -> Void) {
        isLoading = true
        error = nil
        var allArticles = [Article]()
        let dispatchGroup = DispatchGroup()
        var feedErrors: [String: FeedError] = [:]
        
        for feed in feeds {
            dispatchGroup.enter()
            let urlString = feed.0
            let sourceName = feed.1
            
            guard let url = URL(string: urlString) else {
                feedErrors[sourceName] = .invalidURL
                dispatchGroup.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { dispatchGroup.leave() }
                
                if let error = error {
                    print("Failed to fetch \(sourceName): \(error)")
                    feedErrors[sourceName] = .networkError
                    return
                }
                
                guard let data = data,
                      let xmlString = String(data: data, encoding: .utf8) else {
                    feedErrors[sourceName] = .networkError
                    return
                }
                
                // Basic RSS parsing
                let title = self.extractTitle(from: xmlString)
                let link = self.extractLink(from: xmlString)
                let description = self.extractDescription(from: xmlString)
                
                let article = Article(
                    title: title ?? "No Title",
                    url: link ?? urlString,
                    source: sourceName,
                    date: Date(),
                    summary: description
                )
                allArticles.append(article)
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            if allArticles.isEmpty && !feedErrors.isEmpty {
                completion(.failure(.networkError))
            } else {
                let sorted = allArticles.sorted { $0.date > $1.date }
                completion(.success(sorted))
            }
        }
    }
}

class NewsFeedViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: FeedError?
    
    private let aggregator = RSSAggregator()
    
    func fetchArticles() {
        isLoading = true
        error = nil
        
        aggregator.fetchAllArticles { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            switch result {
            case .success(let articles):
                self.articles = articles
                self.error = nil
            case .failure(let error):
                self.error = error
                self.articles = []
            }
        }
    }
}

struct NewsFeedView: View {
    @StateObject private var viewModel = NewsFeedViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading feeds...")
                        .foregroundColor(.white)
                } else if let error = viewModel.error {
                    ErrorView(error: error, retryAction: viewModel.fetchArticles)
                } else {
                    ArticleListView(articles: viewModel.articles)
                }
            }
            .navigationTitle("News Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.fetchArticles) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .onAppear {
            viewModel.fetchArticles()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.purple.opacity(0.5)]),
                         startPoint: .top,
                         endPoint: .bottom)
            .ignoresSafeArea()
        )
    }
}

struct ErrorView: View {
    let error: FeedError
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("😕")
                .font(.system(size: 64))
            Text(error.description)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            Button("Try Again", action: retryAction)
                .buttonStyle(.bordered)
                .tint(.white)
        }
        .padding()
    }
}

struct ArticleListView: View {
    let articles: [Article]
    
    var body: some View {
        List(articles) { article in
            ArticleRow(article: article)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

struct ArticleRow: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
                .foregroundColor(.white)
            Text(article.source)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            if let summary = article.summary {
                Text(summary)
                    .font(.body)
                    .lineLimit(3)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: article.url) {
                UIApplication.shared.open(url)
            }
        }
    }
} 

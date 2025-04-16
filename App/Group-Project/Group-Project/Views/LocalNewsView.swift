import SwiftUI

struct LocalNewsView: View {
    @EnvironmentObject private var menuState: MenuState
    @StateObject private var viewModel = NewsViewModel()
    @State private var currentPage = 0
    @State private var autoRotationTimer: Timer?
    
    private let articlesPerPage = 4
    
    var currentArticles: [RSSItem] {
        let totalArticles = viewModel.currentArticles
        guard !totalArticles.isEmpty else { return [] }
        
        let startIndex = (currentPage * articlesPerPage) % totalArticles.count
        var articles: [RSSItem] = []
        
        for offset in 0..<articlesPerPage {
            let index = (startIndex + offset) % totalArticles.count
            articles.append(totalArticles[index])
        }
        
        return articles
    }
    
    var totalPages: Int {
        let count = viewModel.currentArticles.count
        return max(1, (count + articlesPerPage - 1) / articlesPerPage)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Local News")
                            .font(.system(size: 34, weight: .bold))
                        Text("Latest updates from your area")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if viewModel.currentArticles.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "newspaper")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No articles available")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    } else {
                        // News Articles Stack
                        VStack(spacing: 20) {
                            // Article Stack
                            VStack(spacing: 20) {
                                ForEach(currentArticles) { article in
                                    NewsArticleCard(article: article)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Navigation Controls
                            if viewModel.currentArticles.count > articlesPerPage {
                                HStack(spacing: 20) {
                                    Button(action: {
                                        withAnimation {
                                            currentPage = (currentPage - 1 + totalPages) % totalPages
                                        }
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(.red)
                                    }
                                    
                                    Text("Page \(currentPage + 1) of \(totalPages)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Button(action: {
                                        withAnimation {
                                            currentPage = (currentPage + 1) % totalPages
                                        }
                                    }) {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    withAnimation {
                        menuState.showingLocalNews = false
                    }
                }
                .foregroundColor(.blue)
            )
            .refreshable {
                await viewModel.fetchLocalNews()
                currentPage = 0
            }
            .task {
                await viewModel.fetchLocalNews()
                setupAutoRotation()
            }
            .onDisappear {
                autoRotationTimer?.invalidate()
                autoRotationTimer = nil
            }
        }
    }
    
    private func setupAutoRotation() {
        // Cancel any existing timer
        autoRotationTimer?.invalidate()
        
        // Create new timer
        autoRotationTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            Task { @MainActor in
                withAnimation {
                    currentPage = (currentPage + 1) % totalPages
                }
            }
        }
    }
}

struct NewsArticleCard: View {
    let article: RSSItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(article.title)
                .font(.system(size: 22, weight: .bold))
                .lineLimit(3)
            
            Text(article.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                if let pubDate = article.pubDate {
                    Text(pubDate.formatted(.dateTime.month().day()))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let url = article.link {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Text("Read More")
                                .foregroundColor(.red)
                            Image(systemName: "arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = article.link {
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    LocalNewsView()
        .environmentObject(MenuState())
} 
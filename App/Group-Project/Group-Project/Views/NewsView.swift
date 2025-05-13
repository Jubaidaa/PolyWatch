import SwiftUI

struct NewsView: View {
    @StateObject private var viewModel = NewsViewModel()
    let isBreakingNews: Bool
    
    var body: some View {
        ScrollView {
            if isBreakingNews {
                VStack(spacing: 20) {
                    Image(systemName: "bolt.horizontal.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Breaking News Coming Soon")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("This feature is currently under development.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                LazyVStack(spacing: 16) {
                    if viewModel.currentArticles.isEmpty {
                        Text("Loading articles...")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(viewModel.currentArticles) { article in
                            NewsItemView(item: article)
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }
                    }
                }
                .padding()
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentArticles)
            }
        }
        .refreshable {
            if !isBreakingNews {
                await viewModel.fetchLocalNews()
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .task {
            if !isBreakingNews {
                await viewModel.fetchLocalNews()
            }
        }
        .navigationTitle(isBreakingNews ? "Breaking News" : "Bay Area News")
    }
}

struct NewsItemView: View {
    let item: RSSItem
    
    // Assign a color based on the source name for visual variety
    private func colorForSource(_ source: String) -> Color {
        let colors: [Color] = [
            .red, .blue, .green, .orange, .purple, .pink, .teal, .indigo
        ]
        let hash = abs(source.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageUrl = item.imageUrl {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            // Source badge
            if !item.source.isEmpty {
                Text(item.source.uppercased())
                    .font(.caption2.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(colorForSource(item.source).opacity(0.15))
                    )
                    .foregroundColor(colorForSource(item.source).opacity(0.9))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    if let pubDate = item.pubDate {
                        Text(pubDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let url = item.link {
                        Button("Read More") {
                            UIApplication.shared.open(url)
                        }
                        .font(.caption.bold())
                        .foregroundColor(colorForSource(item.source))
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = item.link {
                UIApplication.shared.open(url)
            }
        }
    }
} 

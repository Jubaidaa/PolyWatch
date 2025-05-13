import SwiftUI

struct BreakingNewsView: View {
    @StateObject private var viewModel = BreakingNewsViewModel()
    @State private var selectedSource: String?

    var body: some View {
        LazyVStack(spacing: Constants.Padding.standard) {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .padding()
            } else if viewModel.currentArticles.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "newspaper")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    
                    Text("No articles available")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Button("Reload") {
                        Task {
                            await viewModel.fetchBreakingNews()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                VStack(spacing: Constants.Padding.standard) {
                    let filteredArticles = selectedSource.map { source in
                        viewModel.allBreakingNewsArticles.filter { $0.source == source }
                    } ?? viewModel.allBreakingNewsArticles
                    
                    ForEach(filteredArticles) { article in
                        BreakingNewsCard(article: article)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
            }
        }
    }
}

struct BreakingNewsView_Previews: PreviewProvider {
    static var previews: some View {
        BreakingNewsView()
    }
} 
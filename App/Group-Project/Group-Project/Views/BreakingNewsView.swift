import SwiftUI

struct BreakingNewsView: View {
    @EnvironmentObject private var menuState: MenuState
    @StateObject private var viewModel = BreakingNewsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                AppColors.white
                    .ignoresSafeArea()
                    
                VStack(spacing: 0) {
                    // Top bar is already handled by the navigation
                    
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Breaking News")
                                    .font(.system(size: 28, weight: .bold))
                                    .frame(maxWidth: .infinity, alignment: .center)
                        }
                            .padding(.top, 8)
                        .padding(.bottom, 10)

                        if viewModel.isLoading {
                            ProgressView("Loading breaking news...")
                                .padding()
                                    .frame(height: 200)
                        } else if viewModel.currentArticles.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bolt.horizontal.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("No breaking news available.")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(height: 300)
                        } else {
                            LazyVStack(spacing: 20) {
                                ForEach(viewModel.currentArticles) { article in
                                    NewsItemView(item: article)
                                        .id(article.id)
                                }
                                Spacer().frame(height: 60)
                            }
                            .padding(.horizontal)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.currentArticles)
                        }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            menuState.closeAllOverlays()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.red)
                    }
                }
            }
            .task {
                await viewModel.fetchBreakingNews()
            }
        }
    }
}

struct BreakingNewsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Placeholder image
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    Image(systemName: "newspaper")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                // Breaking news label
                HStack {
                    Text("BREAKING")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                    
                    Text("2 hours ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Title
                Text("Major World Event Placeholder")
                    .font(.headline)
                    .lineLimit(2)
                
                // Description
                Text("This is a placeholder for breaking news content. Real news will be integrated here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                // Source and read more
                HStack {
                    Text("Source: News Agency")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Read More")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
        )
    }
}

#Preview {
    BreakingNewsView()
        .environmentObject(MenuState())
} 
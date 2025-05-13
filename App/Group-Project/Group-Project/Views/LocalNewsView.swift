import SwiftUI

struct LocalNewsView: View {
    @EnvironmentObject private var menuState: MenuState
    @StateObject private var viewModel = NewsViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var showScrollToTop = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                AppColors.white
                    .ignoresSafeArea()
                    
                VStack(spacing: 0) {
                    // Top bar is handled by navigation
                    
                    ScrollViewReader { scrollProxy in
                        ScrollView(showsIndicators: true) {
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: geometry.frame(in: .named("scrollView")).minY
                                )
                            }
                            .frame(height: 0)
                            .id("scrollTop")
                            
                            VStack(spacing: 24) {
                                // Header
                                VStack(spacing: 8) {
                                    Text("Local News")
                                        .font(.system(size: 28, weight: .bold))
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    Text("Latest updates from Bay Area sources")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 10)
                                
                                if viewModel.isLoading {
                                    ProgressView()
                                        .padding()
                                        .frame(height: 200)
                                } else if viewModel.currentArticles.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "newspaper")
                                            .font(.largeTitle)
                                            .foregroundColor(.gray)
                                        Text("Loading articles...")
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
                        .coordinateSpace(name: "scrollView")
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            scrollOffset = value
                            showScrollToTop = value < -200
                        }
                        .refreshable {
                            await viewModel.fetchLocalNews()
                        }
                        
                        if showScrollToTop {
                            Button(action: {
                                withAnimation {
                                    scrollProxy.scrollTo("scrollTop", anchor: .top)
                                }
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.red.opacity(0.8))
                                    .shadow(radius: 3)
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                            .transition(.scale.combined(with: .opacity))
                        }
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
                await viewModel.fetchLocalNews()
            }
        }
    }
}

// Preference key for tracking scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct NewsArticleCard: View {
    let article: RSSItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(article.title)
                .font(.system(size: 22, weight: .bold))
                .lineLimit(3)
            
            Text(article.description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
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


struct NewsCard: View {
    let article: ArticleItem
    @State private var showArticleDetail = false

    var body: some View {
        Button(action: {
            showArticleDetail = true
        }) {
            ZStack(alignment: .bottomLeading) {
                // Use URL or asset image
                Group {
                    if article.image.hasPrefix("http") {
                        AsyncImage(url: URL(string: article.image)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "newspaper")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Image(article.image.contains("/") ? "news1" : article.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            @unknown default:
                                Image(article.image.contains("/") ? "news1" : article.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                        .transition(.opacity)
                    } else {
                        Image(article.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .clipped()

                // Improved gradient for better text readability
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .black.opacity(0.3),
                        .black.opacity(0.7),
                        .black.opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 4)

                    HStack(spacing: 4) {
                        Text(article.source)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text(article.date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding()
            }
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showArticleDetail) {
            ArticleDetailView(article: article)
        }
    }
}

// Fallback articles in case RSS feed fails
let fallbackArticles = [
    ArticleItem(
        title: "Breaking News: Major Policy Change",
        image: "news1",
        date: "2 hours ago",
        source: "CNN",
        description: "The government announced a major policy change today that will affect millions of citizens across the country. Officials say the new measures are designed to address growing concerns about economic stability.",
        link: URL(string: "https://www.cnn.com")
    ),
    ArticleItem(
        title: "Local Elections Update",
        image: "news2",
        date: "4 hours ago",
        source: "Fox News",
        description: "Local election officials have released updated information about upcoming races and ballot measures. Voters are encouraged to check registration status before the upcoming deadline.",
        link: URL(string: "https://www.foxnews.com")
    ),
    ArticleItem(
        title: "Community Meeting Highlights",
        image: "news3",
        date: "1 day ago",
        source: "ABC News",
        description: "Yesterday's community meeting addressed several key issues facing residents, including infrastructure improvements and public safety concerns. City officials outlined plans for upcoming projects.",
        link: URL(string: "https://www.abcnews.com")
    )
] 
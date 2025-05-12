import SwiftUI

struct ArticleDetailView: View {
    let article: ArticleItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header image
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
                        } else {
                            Image(article.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    
                    // Article content
                    VStack(alignment: .leading, spacing: 12) {
                        Text(article.title)
                            .font(.title)
                            .fontWeight(.bold)
                            
                        HStack {
                            Text(article.source)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text(article.date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text("This article from \(article.source) was published \(article.date). For more details, please visit the source website.")
                            .font(.body)
                            .padding(.bottom, 16)
                        
                        Button(action: {
                            // Here you would open the source URL in a browser
                            // For now we'll just dismiss the view
                            dismiss()
                        }) {
                            Text("Read full article")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
} 
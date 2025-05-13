import SwiftUI
import WebKit

struct ArticleDetailView: View {
    let article: ArticleItem
    @Environment(\.dismiss) private var dismiss
    @State private var imageHeight: CGFloat = 250
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header image - Full width with proper sizing
                    GeometryReader { geo in
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
                        .frame(width: geo.size.width, height: imageHeight)
                        .clipped()
                        .onAppear {
                            // Ensure image has proper height
                            imageHeight = max(250, geo.size.width * 9/16)
                        }
                    }
                    .frame(height: imageHeight)
                    
                    // Article content with improved spacing and formatting
                    VStack(alignment: .leading, spacing: 16) {
                        Text(article.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 8)
                            
                        HStack {
                            Text(article.source)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text(article.date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Article content - display HTML content if available
                        if article.description.contains("<") && article.description.contains(">") {
                            HTMLContentView(htmlContent: article.description)
                                .frame(minHeight: 200)
                        } else {
                            Text(article.description)
                                .font(.body)
                                .lineSpacing(6)
                        }
                        
                        if let url = article.link {
                            Link(destination: url) {
                                Text("Read full article on \(article.source)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

// HTML Content View to render HTML content
struct HTMLContentView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Create HTML document with proper styling
        let htmlStart = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, system-ui, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
                    font-size: 17px;
                    line-height: 1.6;
                    color: #333;
                    margin: 0;
                    padding: 0;
                }
                img {
                    max-width: 100%;
                    height: auto;
                    margin: 10px 0;
                }
                a {
                    color: #0066cc;
                    text-decoration: none;
                }
                p {
                    margin-bottom: 16px;
                }
            </style>
        </head>
        <body>
        """
        
        let htmlEnd = """
        </body>
        </html>
        """
        
        let fullHTML = htmlStart + htmlContent + htmlEnd
        uiView.loadHTMLString(fullHTML, baseURL: nil)
    }
} 
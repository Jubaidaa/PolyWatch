import Foundation
import FeedKit

struct RSSItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let link: URL?
    let pubDate: Date?
    let description: String
    let imageUrl: URL?
    let source: String
    
    static func == (lhs: RSSItem, rhs: RSSItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.link == rhs.link &&
        lhs.pubDate == rhs.pubDate &&
        lhs.description == rhs.description &&
        lhs.imageUrl == rhs.imageUrl
    }
}

class RSSService: ObservableObject {
    @Published var items: [RSSItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    enum RSSError: Error {
        case invalidURL
        case networkError
        case parsingError
        case feedNotFound
    }
    
    func fetchRSS(from urlString: String) async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        guard let url = URL(string: urlString) else {
            await MainActor.run {
                error = RSSError.invalidURL
                isLoading = false
            }
            return
        }
        
        // Extract the source name from the URL
        let sourceName = url.host?
            .replacingOccurrences(of: "www.", with: "")
            .components(separatedBy: ".")[0] ?? "News"
        
        do {
            let parser = FeedParser(URL: url)
            let result = await withCheckedContinuation { continuation in
                parser.parseAsync { result in
                    continuation.resume(returning: result)
                }
            }
            
            // Process feed and create items to return
            let localItems = await processRSSFeed(result: result, sourceName: sourceName)
            
            // Update the published property on the main thread
            await MainActor.run {
                self.items = localItems
                self.isLoading = false
            }
        } catch {
            print("Error fetching RSS: \(error)")
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    private func processRSSFeed(result: Result<Feed, ParserError>, sourceName: String) async -> [RSSItem] {
        var processedItems: [RSSItem] = []
        
        switch result {
        case .success(let feed):
            // Handle RSS feed format
            if let rssFeed = feed.rssFeed {
                for item in rssFeed.items ?? [] {
                    let description = item.description ?? item.content?.contentEncoded ?? ""
                    
                    // Look for image in content or media
                    var imageUrl: URL? = nil
                    if let mediaContent = item.media?.mediaContents?.first?.attributes?.url {
                        imageUrl = URL(string: mediaContent)
                    } else if let enclosureUrl = item.enclosure?.attributes?.url {
                        imageUrl = URL(string: enclosureUrl)
                    } else {
                        // Try to extract image URL from HTML content
                        let imgRegex = try? NSRegularExpression(pattern: "<img[^>]+src=\"([^\"]+)\"", options: [])
                        if let match = imgRegex?.firstMatch(in: description, options: [], range: NSRange(location: 0, length: description.count)) {
                            if let range = Range(match.range(at: 1), in: description) {
                                let urlString = String(description[range])
                                imageUrl = URL(string: urlString)
                            }
                        }
                    }
                    
                    let rssItem = RSSItem(
                        title: item.title ?? "No Title",
                        link: URL(string: item.link ?? ""),
                        pubDate: item.pubDate,
                        description: description,
                        imageUrl: imageUrl,
                        source: sourceName
                    )
                    
                    processedItems.append(rssItem)
                }
            }
            // Handle Atom feed format
            else if let atomFeed = feed.atomFeed {
                for entry in atomFeed.entries ?? [] {
                    let description = entry.summary?.value ?? entry.content?.value ?? ""
                    
                    let rssItem = RSSItem(
                        title: entry.title ?? "No Title",
                        link: URL(string: entry.links?.first?.attributes?.href ?? ""),
                        pubDate: entry.published ?? entry.updated,
                        description: description,
                        imageUrl: nil, // Atom doesn't typically include images in the same way
                        source: sourceName
                    )
                    
                    processedItems.append(rssItem)
                }
            }
            // Handle JSON feed format - using dictionary approach to avoid property name issues
            else if let jsonFeed = feed.jsonFeed {
                for item in jsonFeed.items ?? [] {
                    // Get content from description first
                    var description = ""
                    
                    // Try to get content using JSON dictionary access which is more reliable
                    if let itemDict = item as? [String: Any] {
                        if let contentHtml = itemDict["content_html"] as? String {
                            description = contentHtml
                        } else if let contentText = itemDict["content_text"] as? String {
                            description = contentText
                        } else {
                            description = "No description available"
                        }
                    }
                    
                    let rssItem = RSSItem(
                        title: item.title ?? "No Title",
                        link: URL(string: item.url ?? ""),
                        pubDate: nil, // Use nil since we can't reliably access date fields
                        description: description,
                        imageUrl: URL(string: item.image ?? ""),
                        source: sourceName
                    )
                    
                    processedItems.append(rssItem)
                }
            }
            else {
                await MainActor.run {
                    error = RSSError.feedNotFound
                }
                return []
            }
        case .failure(let error):
            print("Feed parsing error: \(error)")
            await MainActor.run {
                self.error = error
            }
            return []
        }
        
        return processedItems
    }
} 
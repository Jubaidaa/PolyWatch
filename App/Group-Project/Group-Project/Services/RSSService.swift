import Foundation

struct RSSItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let link: URL?
    let pubDate: Date?
    let description: String
    let imageUrl: URL?
    
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
    }
    
    func fetchRSS(from urlString: String) async {
        isLoading = true
        error = nil
        
        guard let url = URL(string: urlString) else {
            error = RSSError.invalidURL
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let parser = XMLParser(data: data)
            let rssParser = RSSParser()
            parser.delegate = rssParser
            
            if parser.parse() {
                await MainActor.run {
                    self.items = rssParser.items
                    self.isLoading = false
                }
            } else {
                throw RSSError.parsingError
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
}

class RSSParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentImageUrl = ""
    private var parsingItem = false
    
    var items: [RSSItem] = []
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "item" {
            parsingItem = true
            currentTitle = ""
            currentDescription = ""
            currentLink = ""
            currentPubDate = ""
            currentImageUrl = ""
        }
        
        // Check for media content or enclosure for images
        if elementName == "media:content" || elementName == "enclosure" {
            if let urlString = attributeDict["url"] {
                currentImageUrl = urlString
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if parsingItem {
            switch currentElement {
            case "title": currentTitle += string
            case "description": currentDescription += string
            case "link": currentLink += string
            case "pubDate": currentPubDate += string
            default: break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            
            let pubDate = dateFormatter.date(from: currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines))
            let link = URL(string: currentLink.trimmingCharacters(in: .whitespacesAndNewlines))
            let imageUrl = URL(string: currentImageUrl)
            
            let item = RSSItem(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                link: link,
                pubDate: pubDate,
                description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                imageUrl: imageUrl
            )
            
            items.append(item)
            parsingItem = false
        }
    }
} 
else if let jsonFeed = feed.jsonFeed {
    for item in jsonFeed.items ?? [] {
        // Get content from description first
        var description = ""
        
        // Use the properties directly instead of casting to dictionary
        if let contentHtml = item.contentHtml {
            description = contentHtml
        } else if let contentText = item.contentText {
            description = contentText
        } else {
            description = "No description available"
        }
        
        let rssItem = RSSItem(
            title: item.title ?? "No Title",
            link: URL(string: item.url ?? ""),
            pubDate: item.datePublished, // Use the actual date property
            description: description,
            imageUrl: URL(string: item.image ?? ""),
            source: sourceName
        )
        
        processedItems.append(rssItem)
    }
} 
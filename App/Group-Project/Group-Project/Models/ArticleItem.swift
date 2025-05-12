import Foundation

struct ArticleItem: Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let date: String
    let source: String
} 
import Foundation

struct Election: Codable, Identifiable {
    let id: String
    let name: String
    let electionDay: String
    let ocdDivisionId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case electionDay = "election_day"
        case ocdDivisionId = "ocd_division_id"
    }
}

struct ElectionsResponse: Codable {
    let elections: [Election]
}

enum ElectionError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case networkError
    
    var description: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .invalidData: return "Invalid data received"
        case .networkError: return "Network error occurred"
        }
    }
} 
import Foundation

struct Election: Codable, Identifiable {
    let id: String
    let name: String
    let electionDay: String
    let ocdDivisionId: String?
    
    static let stateNames: [String: String] = [
        "al": "Alabama", "ak": "Alaska", "az": "Arizona", "ar": "Arkansas", "ca": "California",
        "co": "Colorado", "ct": "Connecticut", "de": "Delaware", "fl": "Florida", "ga": "Georgia",
        "hi": "Hawaii", "id": "Idaho", "il": "Illinois", "in": "Indiana", "ia": "Iowa",
        "ks": "Kansas", "ky": "Kentucky", "la": "Louisiana", "me": "Maine", "md": "Maryland",
        "ma": "Massachusetts", "mi": "Michigan", "mn": "Minnesota", "ms": "Mississippi", "mo": "Missouri",
        "mt": "Montana", "ne": "Nebraska", "nv": "Nevada", "nh": "New Hampshire", "nj": "New Jersey",
        "nm": "New Mexico", "ny": "New York", "nc": "North Carolina", "nd": "North Dakota", "oh": "Ohio",
        "ok": "Oklahoma", "or": "Oregon", "pa": "Pennsylvania", "ri": "Rhode Island", "sc": "South Carolina",
        "sd": "South Dakota", "tn": "Tennessee", "tx": "Texas", "ut": "Utah", "vt": "Vermont",
        "va": "Virginia", "wa": "Washington", "wv": "West Virginia", "wi": "Wisconsin", "wy": "Wyoming",
        "dc": "District of Columbia"
    ]
    
    var stateName: String? {
        guard let divisionId = ocdDivisionId else { return nil }
        let stateCode = divisionId.replacingOccurrences(of: "ocd-division/country:us/state:", with: "").lowercased()
        return Election.stateNames[stateCode]
    }
    
    var electionInfoURL: URL? {
        // Construct URL based on division ID or default to general elections page
        if let divisionId = ocdDivisionId {
            let state = divisionId.replacingOccurrences(of: "ocd-division/country:us/state:", with: "")
            return URL(string: "https://www.vote.org/state/\(state)")
        }
        return URL(string: "https://www.vote.org/elections/")
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case electionDay = "electionDay"
        case ocdDivisionId = "ocdDivisionId"
    }
}

struct ElectionsResponse: Codable {
    let kind: String
    let elections: [Election]
}

enum ElectionError: Error, Equatable {
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
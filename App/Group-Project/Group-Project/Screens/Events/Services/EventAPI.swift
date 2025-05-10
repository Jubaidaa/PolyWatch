import Foundation

enum EventAPIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
}

class EventAPI {
    // Using a public organization ID for now - you may want to replace this with your organization's ID
    private let organizationId = "1"  // Replace with your organization ID
    private let baseURL = "https://api.mobilize.us/v1"
    private let pageSize = 50
    private var nextCursor: String?
    
    // Political event types
    private let validEventTypes = [
        "RALLY", "TOWN_HALL", "CANVASS", "MEETING", "COMMUNITY", 
        "FUNDRAISER", "TRAINING", "PETITION", "VISIBILITY_EVENT",
        "PHONE_BANK", "TEXT_BANK", "VOTER_REG"
    ]
    
    // Political tags to look for
    private let politicalTags = [
        "politics", "democratic", "republican", "campaign", "election",
        "voting", "voter", "ballot", "primary", "caucus", "debate",
        "townhall", "rally", "protest", "activism", "advocacy",
        "legislation", "policy", "congress", "senate", "house",
        "governor", "mayor", "local", "state", "federal"
    ]
    
    // US States and their abbreviations
    private let states = [
        "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
        "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
        "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
        "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
        "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
    ]
    
    func fetchEvents(page: Int = 1, state: String? = nil, city: String? = nil) async throws -> [Event] {
        // Use the organization-scoped endpoint
        var components = URLComponents(string: "\(baseURL)/organizations/\(organizationId)/events")!
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "per_page", value: String(pageSize)),
            URLQueryItem(name: "timeslot_start", value: "gte_now"),  // Only get future events
            URLQueryItem(name: "exclude_full", value: "true"),       // Exclude full events
            URLQueryItem(name: "sort_by", value: "timeslot_start"),
            URLQueryItem(name: "sort_direction", value: "asc")
        ]
        
        // Use cursor if available, otherwise start from beginning
        if let cursor = nextCursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        
        // Add event types
        for type in validEventTypes {
            queryItems.append(URLQueryItem(name: "event_types", value: type))
        }
        
        // Add location filters if provided
        if let state = state {
            queryItems.append(URLQueryItem(name: "state", value: state))
        }
        if let city = city {
            queryItems.append(URLQueryItem(name: "locality", value: city))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("❌ Invalid URL constructed")
            throw EventAPIError.invalidURL
        }
        
        print("🔍 Fetching events from URL: \(url)")
        
        // Create request with headers
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Note: Add your API key here if needed
        // request.setValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📦 Raw API Response:")
                print(responseString)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw EventAPIError.invalidResponse
            }
            
            print("📡 Response status code: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let mobilizeResponse = try decoder.decode(MobilizeResponse.self, from: data)
                print("✅ Successfully decoded \(mobilizeResponse.data.count) events")
                
                // Update next cursor for pagination
                if let nextURL = mobilizeResponse.next,
                   let nextComponents = URLComponents(string: nextURL),
                   let cursor = nextComponents.queryItems?.first(where: { $0.name == "cursor" })?.value {
                    self.nextCursor = cursor
                } else {
                    self.nextCursor = nil
                }
                
                // Log details about each event
                for event in mobilizeResponse.data {
                    print("\nEvent Details:")
                    print("Title: \(event.title)")
                    print("Type: \(event.event_type ?? "N/A")")
                    print("Timeslots: \(event.timeslots.count)")
                    if let firstTimeslot = event.timeslots.first {
                        let startDate = Date(timeIntervalSince1970: TimeInterval(firstTimeslot.start_date))
                        let endDate = Date(timeIntervalSince1970: TimeInterval(firstTimeslot.end_date))
                        print("Start Date: \(startDate)")
                        print("End Date: \(endDate)")
                    }
                    print("Image URL: \(event.featured_image_url ?? "N/A")")
                    print("Location: \(event.location?.venue ?? "N/A")")
                }
                
                return mobilizeResponse.data.map { $0.toEvent() }
            default:
                print("❌ Server error: \(httpResponse.statusCode)")
                throw EventAPIError.serverError(httpResponse.statusCode)
            }
        } catch let error as DecodingError {
            print("❌ Decoding error details: \(error)")
            throw EventAPIError.decodingError(error)
        } catch {
            print("❌ Network error: \(error)")
            throw EventAPIError.networkError(error)
        }
    }
}

// MARK: - MobilizeAmerica API Models
struct MobilizeResponse: Codable {
    let data: [MobilizeEvent]
    let next: String?
    let previous: String?
    let count: Int
}

struct MobilizeEvent: Codable {
    let id: Int
    let title: String
    let description: String?
    let browser_url: String?
    let featured_image_url: String?
    let sponsor: MobilizeOrganization?
    let timeslots: [MobilizeTimeslot]
    let location: MobilizeLocation?
    let event_type: String?
    let is_virtual: Bool?
    let tags: [MobilizeTag]?
    
    func toEvent() -> Event {
        let firstTimeslot = timeslots.first
        let startDate = firstTimeslot != nil ? Date(timeIntervalSince1970: TimeInterval(firstTimeslot!.start_date)) : Date()
        let endDate = firstTimeslot != nil ? Date(timeIntervalSince1970: TimeInterval(firstTimeslot!.end_date)) : nil
        
        // Extract state from location if available
        var stateTag = ""
        if let venue = location?.venue {
            // Try to find a state abbreviation in the venue
            for state in ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
                         "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
                         "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
                         "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
                         "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"] {
                if venue.uppercased().contains(state) {
                    stateTag = state.lowercased()
                    break
                }
            }
        }
        
        // Combine existing tags with state tag and add political tags if relevant
        var allTags = tags?.map { $0.name } ?? []
        if !stateTag.isEmpty {
            allTags.append(stateTag)
        }
        
        // Add political tag if the event seems political
        let titleAndDescription = (title + " " + (description ?? "")).lowercased()
        for politicalTag in ["politics", "democratic", "republican", "campaign", "election",
                           "voting", "voter", "ballot", "primary", "caucus", "debate",
                           "townhall", "rally", "protest", "activism", "advocacy",
                           "legislation", "policy", "congress", "senate", "house",
                           "governor", "mayor", "local", "state", "federal"] {
            if titleAndDescription.contains(politicalTag) && !allTags.contains(politicalTag) {
                allTags.append(politicalTag)
            }
        }
        
        return Event(
            title: title,
            date: startDate,
            endDate: endDate,
            location: location?.venue ?? "Online/Location TBA",
            description: (description ?? "") + "\n\nSource: MobilizeAmerica",
            imageURL: featured_image_url,
            price: nil,
            registrationRequired: true,
            registrationURL: browser_url,
            organizer: sponsor?.name ?? "",
            tags: allTags,
            status: .upcoming
        )
    }
}

struct MobilizeOrganization: Codable {
    let name: String
}

struct MobilizeTimeslot: Codable {
    let id: Int
    let start_date: Int
    let end_date: Int
}

struct MobilizeLocation: Codable {
    let venue: String?
}

struct MobilizeTag: Codable {
    let name: String
} 
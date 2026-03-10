// Event.swift
// Defines the Event model and the EventFilter enum

import Foundation

/// Filters for the EventsView
enum EventFilter: String, CaseIterable, Identifiable {
    case all
    case today
    case thisWeek
    case upcoming
    case free

    var id: String { rawValue }

    /// User-friendly title for each filter
    var title: String {
        switch self {
        case .all:      return "All Events"
        case .today:    return "Today"
        case .thisWeek: return "This Week"
        case .upcoming: return "Upcoming"
        case .free:     return "Free"
        }
    }
}

/// Your main Event model
struct Event: Identifiable, Codable {
    var id = UUID()
    let title: String
    let date: Date
    let endDate: Date?
    let location: String
    let description: String
    let imageURL: String?
    let price: Price?
    let registrationRequired: Bool
    let registrationURL: String?
    let organizer: String
    let tags: [String]
    let status: Status
    let state: String?
    
    // Add standard memberwise initializer
    init(title: String, date: Date, endDate: Date?, location: String, description: String, 
         imageURL: String?, price: Price?, registrationRequired: Bool, registrationURL: String?,
         organizer: String, tags: [String], status: Status, state: String?) {
        self.title = title
        self.date = date
        self.endDate = endDate
        self.location = location
        self.description = description
        self.imageURL = imageURL
        self.price = price
        self.registrationRequired = registrationRequired
        self.registrationURL = registrationURL
        self.organizer = organizer
        self.tags = tags
        self.status = status
        self.state = state
    }
    
    enum CodingKeys: String, CodingKey {
        case title, date, endDate, location, description, imageURL
        case price, registrationRequired, registrationURL, organizer, tags
        case status, state
        // Note: id is intentionally excluded since we generate it
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(Date.self, forKey: .date)
        endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        location = try container.decode(String.self, forKey: .location)
        description = try container.decode(String.self, forKey: .description)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        price = try container.decodeIfPresent(Price.self, forKey: .price)
        registrationRequired = try container.decode(Bool.self, forKey: .registrationRequired)
        registrationURL = try container.decodeIfPresent(String.self, forKey: .registrationURL)
        organizer = try container.decode(String.self, forKey: .organizer)
        tags = try container.decode([String].self, forKey: .tags)
        status = try container.decode(Status.self, forKey: .status)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        // id is generated automatically by the default initializer
    }

    enum Status: String, Codable {
        case upcoming
        case almostFull = "almost_full"
        case soldOut = "sold_out"
        case cancelled
    }

    struct Price: Codable {
        let amount: Double
        let currency: String

        var formatted: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency
            return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
        }

        static let free = Price(amount: 0, currency: "USD")
    }

    var isFree: Bool {
        return price == nil || price?.amount == 0
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d, h:mm a"
        return formatter.string(from: date)
    }
}


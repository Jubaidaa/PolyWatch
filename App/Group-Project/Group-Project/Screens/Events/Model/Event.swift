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
    let id = UUID()
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


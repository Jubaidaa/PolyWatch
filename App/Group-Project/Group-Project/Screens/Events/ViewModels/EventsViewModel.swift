import SwiftUI
import Foundation

@MainActor
class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentPage = 1
    @Published var hasMorePages = true
    
    private let eventAPI = EventAPI()
    
    // Helper function to check if an event is within the last 2 weeks
    private func isEventRecent(_ event: Event) -> Bool {
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        return event.date >= twoWeeksAgo
    }
    
    // Helper function to check if an event is today
    private func isEventToday(_ event: Event) -> Bool {
        Calendar.current.isDateInToday(event.date)
    }
    
    // Helper function to check if an event is this week
    private func isEventThisWeek(_ event: Event) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let weekOfYear = calendar.component(.weekOfYear, from: today)
        let year = calendar.component(.yearForWeekOfYear, from: today)
        
        let eventWeek = calendar.component(.weekOfYear, from: event.date)
        let eventYear = calendar.component(.yearForWeekOfYear, from: event.date)
        
        return weekOfYear == eventWeek && year == eventYear
    }
    
    // Helper function to check if an event is upcoming
    private func isEventUpcoming(_ event: Event) -> Bool {
        event.date > Date()
    }
    
    func loadEvents(refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            events = []
            hasMorePages = true
        }
        
        guard hasMorePages else { return }
        
        isLoading = true
        error = nil
        
        do {
            let newEvents = try await eventAPI.fetchEvents(page: currentPage)
            print("Fetched \(newEvents.count) events from API")
            
            // Log all events and their dates
            print("\nAll events from API:")
            for event in newEvents {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .full
                dateFormatter.timeStyle = .short
                print("Event: \(event.title)")
                print("Date: \(dateFormatter.string(from: event.date))")
                print("Is Today: \(Calendar.current.isDateInToday(event.date))")
                print("Is This Week: \(isEventThisWeek(event))")
                print("Is Upcoming: \(isEventUpcoming(event))")
                print("---")
            }
            
            // Filter events based on date only
            let filteredEvents = newEvents.filter { event in
                // Only keep events that are happening now or in the future
                let isFutureEvent = event.date > Date()
                if !isFutureEvent {
                    print("Event filtered out - in the past: \(event.title)")
                }
                return isFutureEvent
            }
            
            print("\nTotal valid events after filtering: \(filteredEvents.count)")
            
            let sortedEvents = filteredEvents.sorted { $0.date < $1.date } // Sort chronologically
            events.append(contentsOf: sortedEvents)
            print("\nTotal events after appending: \(events.count)")
            
            // Log final events and their categories
            print("\nFinal events in each category:")
            print("Today: \(events.filter { isEventToday($0) }.count)")
            print("This Week: \(events.filter { isEventThisWeek($0) }.count)")
            print("Upcoming: \(events.filter { isEventUpcoming($0) }.count)")
            
            currentPage += 1
            hasMorePages = filteredEvents.count >= 50 // crude check, Mobilize API doesn't provide pagination info
        } catch {
            print("Error loading events: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
    }
    
    // Function to get filtered events based on the selected filter
    func getFilteredEvents(filter: EventFilter) -> [Event] {
        let filtered = switch filter {
        case .all:
            events
        case .today:
            events.filter { isEventToday($0) }
        case .thisWeek:
            events.filter { isEventThisWeek($0) }
        case .upcoming:
            events.filter { isEventUpcoming($0) }
        case .free:
            events.filter { $0.isFree }
        }
        print("Filtered events for \(filter.title): \(filtered.count)")
        return filtered
    }
} 
import SwiftUI
import Foundation

class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    
    func fetchEvents() {
        isLoading = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.events = [
                Event(
                    title: "Local Town Hall",
                    date: Date().addingTimeInterval(86400),
                    location: "City Hall",
                    description: "Discussion about local policies"
                ),
                Event(
                    title: "Community Meeting",
                    date: Date().addingTimeInterval(172800),
                    location: "Community Center",
                    description: "Open forum for community concerns"
                )
            ]
            self.isLoading = false
        }
    }
} 
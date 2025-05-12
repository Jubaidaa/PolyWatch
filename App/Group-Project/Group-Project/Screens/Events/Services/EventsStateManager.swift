import Foundation

class EventsStateManager: ObservableObject {
    @Published var selectedState: String?
    
    init() {
        // Initialize with no state selected
        selectedState = nil
    }
    
    func setState(_ state: String?) {
        selectedState = state
    }
} 
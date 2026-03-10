import SwiftUI

class StateManager: ObservableObject {
    @Published var selectedState: String? {
        didSet {
            if let state = selectedState {
                UserDefaults.standard.set(state, forKey: "userSelectedState")
            } else {
                UserDefaults.standard.removeObject(forKey: "userSelectedState")
            }
        }
    }
    
    init() {
        self.selectedState = UserDefaults.standard.string(forKey: "userSelectedState")
    }
    
    func clearState() {
        selectedState = nil
    }
} 
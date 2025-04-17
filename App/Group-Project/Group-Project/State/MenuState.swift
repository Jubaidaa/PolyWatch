import SwiftUI

class MenuState: ObservableObject {
    @Published var isShowing = false
    @Published var showingCalendar = false
    @Published var showingVoterRegistration = false
    @Published var showingHelp = false
    @Published var showingLocalNews = false
    @Published var showingBreakingNews = false
    @Published var showingEvents = false
} 
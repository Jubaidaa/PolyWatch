import SwiftUI

public class MenuState: ObservableObject {
    // Add an identifier to help debug multiple instances
    let id = UUID()
    
    @Published var isShowing = false
    @Published var showingCalendar = false
    @Published var showingVoterRegistration = false
    @Published var showingHelp = false
    @Published var showingLocalNews = false
    @Published var showingBreakingNews = false
    @Published var showingEvents = false
    
    // Function to close all overlays at once
    func closeAllOverlays() {
        withAnimation {
            isShowing = false
            showingCalendar = false
            showingVoterRegistration = false
            showingHelp = false
            showingLocalNews = false
            showingBreakingNews = false
            showingEvents = false
        }
    }
    
    // Function to return to main view
    func returnToMainView() {
        closeAllOverlays()
        NotificationCenter.default.post(name: Notification.Name("returnToMainView"), object: nil)
    }
} 
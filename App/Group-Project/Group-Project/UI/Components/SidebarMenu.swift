// SidebarMenu.swift
// Defines the shared MenuState and the sidebar menu UI

import SwiftUI
import Combine

/// Global state object to manage menu visibility
class MenuState: ObservableObject {
    // Add an identifier to help debug multiple instances
    let id = UUID()
    
    @Published var isShowing                = false
    @Published var showingCalendar          = false
    @Published var showingVoterRegistration = false
    @Published var showingLocalNews         = false
    @Published var showingBreakingNews      = false

    // Newly added to support GlobalMenuModifier.swift
    @Published var showingHelp              = false
    @Published var showingEvents            = false
    
    // Function to close all overlays at once with a more robust implementation
    func closeAllOverlays() {
        #if DEBUG
        print("🚨 MenuState[\(self.id)] - closeAllOverlays() called")
        print("   BEFORE: showingVoterRegistration: \(self.showingVoterRegistration)")
        print("   BEFORE: showingCalendar: \(self.showingCalendar)")
        #endif
        
        // To guarantee navigation works, we'll shut down all overlays in two phases
        // First, close all content overlays (panels)
        withAnimation(.easeInOut(duration: 0.2)) {
            self.showingCalendar = false
            self.showingVoterRegistration = false
            self.showingLocalNews = false
            self.showingBreakingNews = false
            self.showingHelp = false
            self.showingEvents = false
        }
        
        // Give a small delay before closing the sidebar
        // This ensures the other dismissals have time to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.isShowing = false
            }
            
            #if DEBUG
            print("✅ MenuState[\(self.id)] - All overlays should be closed now")
            print("   isShowing: \(self.isShowing)")
            print("   showingEvents: \(self.showingEvents)")
            print("   showingCalendar: \(self.showingCalendar)")
            print("   showingLocalNews: \(self.showingLocalNews)")
            print("   showingBreakingNews: \(self.showingBreakingNews)")
            print("   showingVoterRegistration: \(self.showingVoterRegistration)")
            print("   showingHelp: \(self.showingHelp)")
            #endif
        }
    }
    
    // Add the function to return to main view
    func returnToMainView() {
        // First close all overlays
        closeAllOverlays()
        
        // Then post a notification that we want to return to main view
        NotificationCenter.default.post(name: Notification.Name("returnToMainView"), object: nil)
    }
}

// Note: GlobalMenuModifier is defined in GlobalMenuModifier.swift

struct SidebarMenuContent: View {
    @EnvironmentObject private var menuState: MenuState
    let onLogoTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    withAnimation {
                        menuState.closeAllOverlays()
                    }
                }) {
                    Text("POLYWATCH")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.white)
                }
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        menuState.isShowing = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: Constants.Dimensions.iconSize))
                        .foregroundColor(AppColors.white)
                }
            }
            .padding(.horizontal, Constants.Padding.standard)
            .padding(.vertical, Constants.Padding.vertical)

            // Menu Items
            VStack(spacing: 16) {
                MenuButton(
                    title: "Breaking News",
                    icon: "bolt"
                ) {
                    withAnimation {
                        menuState.isShowing = false
                        menuState.showingBreakingNews = true
                    }
                }

                MenuButton(
                    title: "Local News",
                    icon: "doc.text"
                ) {
                    withAnimation {
                        menuState.isShowing = false
                        menuState.showingLocalNews = true
                    }
                }

                MenuButton(
                    title: "Register to Vote",
                    icon: "checkmark.circle"
                ) {
                    withAnimation {
                        menuState.isShowing = false
                        menuState.showingVoterRegistration = true
                        #if DEBUG
                        print("🔍 Register to Vote button tapped")
                        print("   menuState ID: \(menuState.id)")
                        print("   showingVoterRegistration: \(menuState.showingVoterRegistration)")
                        #endif
                    }
                }

                MenuButton(
                    title: "Upcoming Events",
                    icon: "calendar"
                ) {
                    withAnimation {
                        menuState.isShowing = false
                        menuState.showingCalendar = true
                        #if DEBUG
                        print("🔍 Upcoming Events button tapped")
                        print("   menuState ID: \(menuState.id)")
                        print("   showingCalendar: \(menuState.showingCalendar)")
                        #endif
                    }
                }

                MenuButton(
                    title: "Get Help",
                    icon: "questionmark.circle"
                ) {
                    withAnimation {
                        // First close all overlays
                        menuState.closeAllOverlays()
                        // Using asyncAfter to ensure the overlays are closed before showing help
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                menuState.showingHelp = true
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Constants.Padding.standard)
            .padding(.bottom, Constants.Padding.standard)

            Spacer()

            // Footer
            Text("© 2024 POLYWATCH")
                .font(.system(size: 12))
                .foregroundColor(AppColors.white.opacity(0.7))
                .padding(.bottom, Constants.Padding.standard)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 320)
        .background(AppColors.red)
        .cornerRadius(Constants.Dimensions.cornerRadius)
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Circle()
                    .fill(AppColors.white.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.white)
                    )

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.white)

                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


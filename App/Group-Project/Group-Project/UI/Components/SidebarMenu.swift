// SidebarMenu.swift
// Defines the shared MenuState and the sidebar menu UI

import SwiftUI
import Combine

/// Global state object to manage menu visibility
class MenuState: ObservableObject {
    @Published var isShowing                = false
    @Published var showingCalendar          = false
    @Published var showingVoterRegistration = false
    @Published var showingLocalNews         = false
    @Published var showingBreakingNews      = false

    // Newly added to support GlobalMenuModifier.swift
    @Published var showingHelp              = false
    @Published var showingEvents            = false
}

// Note: GlobalMenuModifier is defined in GlobalMenuModifier.swift

struct SidebarMenuContent: View {
    @EnvironmentObject private var menuState: MenuState
    let onLogoTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onLogoTap) {
                    Text("POLYWATCH")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        menuState.isShowing = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

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
                    }
                }

                MenuButton(
                    title: "Upcoming Events",
                    icon: "calendar"
                ) {
                    withAnimation {
                        menuState.isShowing = false
                        menuState.showingCalendar = true
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            Spacer()

            // Footer
            Text("© 2024 POLYWATCH")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 320)
        .background(Color(red: 0.85, green: 0.15, blue: 0.15))
        .cornerRadius(12)
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
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)

                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


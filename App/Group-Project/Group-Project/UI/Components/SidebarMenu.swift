// SidebarMenu.swift
// Defines the shared MenuState and the sidebar menu UI

import SwiftUI
import Combine

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
                    title: "Election Calendar",
                    icon: "calendar"
                ) {
                    withAnimation {
                        menuState.isShowing = false
                        menuState.showingCalendar = true
                        #if DEBUG
                        print("🔍 Election Calendar button tapped")
                        print("   menuState ID: \(menuState.id)")
                        print("   showingCalendar: \(menuState.showingCalendar)")
                        #endif
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


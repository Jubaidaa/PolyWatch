//
//  Group_ProjectApp.swift
//  Group-Project
//
//  Created by Jubaidaa on 4/11/25.
//

import SwiftUI
import UserNotifications

@main
struct Group_ProjectApp: App {
    // Create single instances for the entire app
    @StateObject private var stateManager = StateManager()
    @StateObject private var menuState = MenuState()
    @StateObject private var notificationService = NotificationService()
    
    init() {
        // Request notification permissions when the app launches
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView(rootMenuState: menuState)
                .environmentObject(stateManager)
                .environmentObject(menuState)
                .environmentObject(notificationService)
                .onAppear {
                    // Schedule notifications when the app appears
                    notificationService.requestAuthorization()
                }
        }
    }
}

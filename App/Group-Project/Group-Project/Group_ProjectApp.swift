//
//  Group_ProjectApp.swift
//  Group-Project
//
//  Created by Jubaidaa on 4/11/25.
//

import SwiftUI

@main
struct Group_ProjectApp: App {
    // Create single instances for the entire app
    @StateObject private var stateManager = StateManager()
    @StateObject private var menuState = MenuState()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView(rootMenuState: menuState)
                .environmentObject(stateManager)
                .environmentObject(menuState)
        }
    }
}

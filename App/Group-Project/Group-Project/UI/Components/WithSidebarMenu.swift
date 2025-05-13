import SwiftUI
import Combine

// Import MenuState from the State module
@_exported import struct Foundation.UUID

struct WithSidebarMenu<Content: View>: View {
    @StateObject private var menuState = MenuState()
    let content: Content
    let onLogoTap: () -> Void

    init(@ViewBuilder content: () -> Content, onLogoTap: @escaping () -> Void) {
        self.content = content()
        self.onLogoTap = onLogoTap
    }

    var body: some View {
        ZStack {
            content
                .environmentObject(menuState)

            if menuState.isShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            menuState.isShowing = false
                        }
                    }

                HStack {
                    SidebarMenuContent(onLogoTap: onLogoTap)
                        .environmentObject(menuState)
                        .transition(.move(edge: .leading))
                    Spacer()
                }
            }
        }
    }
} 
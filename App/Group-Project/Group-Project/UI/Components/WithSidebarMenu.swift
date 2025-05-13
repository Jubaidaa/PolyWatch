import SwiftUI

struct WithSidebarMenu<Content: View>: View {
    @EnvironmentObject private var menuState: MenuState
    let content: () -> Content
    let onLogoTap: () -> Void

    init(onLogoTap: @escaping () -> Void = {}, @ViewBuilder content: @escaping () -> Content) {
        self.onLogoTap = onLogoTap
        self.content = content
    }

    var body: some View {
        let _: CGFloat = 320
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                TopBarView(
                    onMenuTap: {
                        withAnimation {
                            menuState.isShowing = true
                        }
                    },
                    onLogoTap: onLogoTap,
                    onSearchTap: {}
                )
                content()
            }
            if menuState.isShowing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            menuState.isShowing = false
                        }
                    }
                    .zIndex(1)
            }
            if menuState.isShowing {
                VStack {
                    SidebarMenuContent(onLogoTap: onLogoTap)
                        .environmentObject(menuState)
                        .frame(maxWidth: 320)
                        .padding(.top, 60)
                    Spacer()
                }
                .transition(.move(edge: .leading))
                .zIndex(2)
            }
        }
    }
} 
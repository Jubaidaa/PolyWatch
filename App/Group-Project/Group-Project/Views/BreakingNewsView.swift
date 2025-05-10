import SwiftUI

struct BreakingNewsView: View {
    @EnvironmentObject private var menuState: MenuState
    
    var body: some View {
        NavigationView {
            Text("Breaking News Coming Soon")
                .navigationTitle("Breaking News")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Exit") {
                            menuState.showingBreakingNews = false
                        }
                    }
                }
        }
    }
}

#Preview {
    BreakingNewsView()
        .environmentObject(MenuState())
} 
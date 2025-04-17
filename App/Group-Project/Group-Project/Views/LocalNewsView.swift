import SwiftUI

struct LocalNewsView: View {
    @EnvironmentObject private var menuState: MenuState
    
    var body: some View {
        NavigationView {
            Text("Local News Coming Soon")
                .navigationTitle("Local News")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Exit") {
                            menuState.showingLocalNews = false
                        }
                    }
                }
        }
    }
}

#Preview {
    LocalNewsView()
        .environmentObject(MenuState())
} 
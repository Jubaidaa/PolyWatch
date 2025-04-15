import SwiftUI

struct BreakingNewsView: View {
    @EnvironmentObject private var menuState: MenuState
    @StateObject private var viewModel = NewsViewModel()
    @State private var selectedCategory = "World"
    
    let categories = ["World", "Politics", "Technology", "Health"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Breaking News")
                            .font(.system(size: 34, weight: .bold))
                        Text("Latest World Updates")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Category Picker
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Temporary placeholder content
                    VStack(spacing: 20) {
                        ForEach(1...5, id: \.self) { _ in
                            BreakingNewsCard()
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    withAnimation {
                        menuState.showingBreakingNews = false
                    }
                }
            )
        }
    }
}

struct BreakingNewsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Placeholder image
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    Image(systemName: "newspaper")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                // Breaking news label
                HStack {
                    Text("BREAKING")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                    
                    Text("2 hours ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Title
                Text("Major World Event Placeholder")
                    .font(.headline)
                    .lineLimit(2)
                
                // Description
                Text("This is a placeholder for breaking news content. Real news will be integrated here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                // Source and read more
                HStack {
                    Text("Source: News Agency")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Read More")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
        )
    }
}

#Preview {
    BreakingNewsView()
        .environmentObject(MenuState())
} 
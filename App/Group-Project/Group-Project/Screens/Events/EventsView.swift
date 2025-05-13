import SwiftUI

struct EventsView: View {
    let isModal: Bool
    @StateObject private var viewModel = EventsViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var menuState: MenuState
    @State private var selectedEvent: Event? = nil
    @State private var showDetail: Bool = false
    
    init(isModal: Bool = false) {
        self.isModal = isModal
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar with custom back arrow
            TopBarView(
                onMenuTap: {},
                onLogoTap: {},
                onSearchTap: {},
                showBackButton: true,
                onBackTap: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            // Header
            VStack(spacing: 8) {
                Text("Upcoming Events")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Event List
            List(filteredEvents) { event in
                Button(action: {
                    selectedEvent = event
                    showDetail = true
                }) {
                    VStack(alignment: .leading, spacing: 12) {
                        if let imageURL = event.imageURL, let url = URL(string: imageURL) {
                            HStack {
                                Spacer()
                                AsyncImage(url: url) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle().fill(Color.gray.opacity(0.2))
                                }
                                .frame(width: 140, height: 120)
                                .clipped()
                                .cornerRadius(16)
                                Spacer()
                            }
                        }
                        Text(event.title)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(event.shortFormattedDate)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(event.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                    .frame(maxWidth: 360)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 0)
                }
                .buttonStyle(PlainButtonStyle())
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .onAppear {
                Task { await viewModel.loadEvents() }
            }
            .sheet(isPresented: $showDetail) {
                if let event = selectedEvent {
                    EventDetailSheet(event: event)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Filtering Logic
    var filteredEvents: [Event] {
        let now = Date()
        let calendar = Calendar.current
        let threeMonthsLater = calendar.date(byAdding: .month, value: 3, to: now) ?? now
        
        return viewModel.events.filter { event in
            (event.imageURL != nil && !(event.imageURL?.isEmpty ?? true)) &&
            event.date >= now && event.date <= threeMonthsLater
        }.sorted { $0.date < $1.date }
    }
    
    // Helper function for circle color
    func eventCircleColor(for event: Event) -> Color {
        let tags = event.tags.map { $0.lowercased() }
        if tags.contains(where: { $0.contains("republican") }) {
            return .red
        } else if tags.contains(where: { $0.contains("democrat") || $0.contains("democratic") }) {
            return .blue
        } else {
            return .gray
        }
    }
}

// Event detail sheet
struct EventDetailSheet: View {
    let event: Event
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageURL = event.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.2))
                    }
                    .frame(height: 200)
                    .clipped()
                }
                Text(event.title)
                    .font(.title)
                    .bold()
                Text(event.shortFormattedDate)
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(event.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.body)
                        .padding(.top, 8)
                }
                if let urlString = event.registrationURL, let url = URL(string: urlString) {
                    Link("View Event / Register", destination: url)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                }
            }
            .padding()
        }
    }
} 
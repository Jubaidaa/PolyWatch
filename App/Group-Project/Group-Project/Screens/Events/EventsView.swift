import SwiftUI

struct EventsView: View {
    let isModal: Bool
    @StateObject private var viewModel = EventsViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var menuState: MenuState
    @State private var selectedEvent: Event? = nil
    @State private var showDetail: Bool = false
    @State private var searchText: String = ""
    @State private var selectedFilter: EventFilter = .upcoming
    
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
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search events...", text: $searchText)
                        .font(.system(size: 16))
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach([EventFilter.upcoming, .all, .today, .thisWeek], id: \.self) { filter in
                            Button(action: {
                                selectedFilter = filter
                            }) {
                                Text(filter.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == filter ? AppColors.red : Color(.systemGray6))
                                    .foregroundColor(selectedFilter == filter ? .white : .primary)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.black.opacity(0.2), lineWidth: selectedFilter == filter ? 0 : 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Event List
            if filteredEvents.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text(searchText.isEmpty ? "No events found for this filter" : "No events match your search")
                        .font(.headline)
                        .foregroundColor(.gray)
                    if !searchText.isEmpty {
                        Button("Clear Search") {
                            searchText = ""
                        }
                        .padding()
                        .foregroundColor(AppColors.red)
                    }
                }
                .padding(.top, 60)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
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
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task { await viewModel.loadEvents() }
        }
        .sheet(isPresented: $showDetail) {
            if let event = selectedEvent {
                EventDetailSheet(event: event)
            }
        }
    }
    
    // MARK: - Filtering Logic
    var filteredEvents: [Event] {
        // First apply the selected filter
        let filterResults = viewModel.getFilteredEvents(filter: selectedFilter)
        
        // Filter out the "Political Campaigning" event
        let filteredByTitle = filterResults.filter { event in
            event.title != "Political Campaigning"
        }
        
        // Then apply search if text is not empty
        if searchText.isEmpty {
            return filteredByTitle
        } else {
            return filteredByTitle.filter { event in
                event.title.localizedCaseInsensitiveContains(searchText)
            }
        }
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
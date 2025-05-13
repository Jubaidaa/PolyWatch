import SwiftUI

struct EventsView: View {
    let isModal: Bool
    @StateObject private var viewModel = EventsViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: FilterType = .all
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var menuState: MenuState
    @State private var selectedEvent: Event? = nil
    @State private var showDetail: Bool = false
    
    enum FilterType: String, CaseIterable, Identifiable {
        case all = "All"
        case upcoming = "Upcoming"
        case thisWeek = "This Week"
        var id: String { rawValue }
    }
    
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
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search events...", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding([.horizontal, .top])
            
            // Filter Tabs
            Picker("Filter", selection: $selectedFilter) {
                ForEach(FilterType.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Event List
            List(filteredEvents) { event in
                Button(action: {
                    selectedEvent = event
                    showDetail = true
                }) {
                    HStack(alignment: .top, spacing: 12) {
                        if let imageURL = event.imageURL, let url = URL(string: imageURL) {
                            AsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle().fill(Color.gray.opacity(0.2))
                            }
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.shortFormattedDate)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(event.location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
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
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? now
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        let events = viewModel.events.filter { event in
            (event.imageURL != nil && !(event.imageURL?.isEmpty ?? true)) &&
            (searchText.isEmpty || event.title.localizedCaseInsensitiveContains(searchText))
        }
        
        switch selectedFilter {
        case .all:
            return events.filter { event in
                (event.date >= now && event.date <= threeMonthsLater) ||
                (event.date < now && event.date >= oneWeekAgo)
            }.sorted { $0.date < $1.date }
        case .upcoming:
            return events.filter { event in
                event.date >= now && event.date <= threeMonthsLater
            }.sorted { $0.date < $1.date }
        case .thisWeek:
            return events.filter { event in
                event.date >= startOfWeek && event.date <= endOfWeek
            }.sorted { $0.date < $1.date }
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
                if let desc = event.description {
                    Text(desc)
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
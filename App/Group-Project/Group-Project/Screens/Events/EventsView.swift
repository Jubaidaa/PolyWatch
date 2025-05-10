import SwiftUI

// MARK: - Event Filter
enum EventFilter: String, CaseIterable, Hashable {
    case all, upcoming, today, thisWeek, free
    
    var title: String {
        switch self {
        case .all: return "All"
        case .upcoming: return "Upcoming"
        case .today: return "Today"
        case .thisWeek: return "This Week"
        case .free: return "Free"
        }
    }
}

// MARK: - Events View
struct EventsView: View {
    // MARK: - Properties
    @StateObject private var viewModel = EventsViewModel()
    @EnvironmentObject private var menuState: MenuState
    @State private var searchText = ""
    @State private var selectedFilter: EventFilter = .all
    @State private var selectedEvent: Event?
    @State private var showingEventDetail = false
    
    let isModal: Bool
    
    // MARK: - Computed Properties
    private var filteredEvents: [Event] {
        let searchFiltered = viewModel.events.filter { event in
            if !searchText.isEmpty {
                return event.title.localizedCaseInsensitiveContains(searchText) ||
                       event.location.localizedCaseInsensitiveContains(searchText) ||
                       event.description.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }
        
        return viewModel.getFilteredEvents(filter: selectedFilter)
            .filter { event in
                if !searchText.isEmpty {
                    return event.title.localizedCaseInsensitiveContains(searchText) ||
                           event.location.localizedCaseInsensitiveContains(searchText) ||
                           event.description.localizedCaseInsensitiveContains(searchText)
                }
                return true
            }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.white.ignoresSafeArea()
                VStack(spacing: 0) {
                    searchAndFilterBar
                    content
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isModal {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Exit") {
                            menuState.showingEvents = false
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEventDetail) {
                if let event = selectedEvent {
                    EventDetailView(event: event)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.error = nil }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
            }
        }
        .onAppear {
            Task { await viewModel.loadEvents(refresh: true) }
        }
    }
}

// MARK: - UI Components
private extension EventsView {
    var searchAndFilterBar: some View {
        VStack(spacing: 8) {
            searchBar
            filterBar
        }
        .padding(.vertical, 8)
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search events...", text: $searchText)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(EventFilter.allCases, id: \.self) { filter in
                    FilterButton(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        action: { selectedFilter = filter }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    var content: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.error {
            errorView(error)
        } else if filteredEvents.isEmpty {
            emptyView
        } else {
            eventsListView
        }
    }
    
    var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading events...")
                .progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
    }
    
    func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Error loading events")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") {
                Task { await viewModel.loadEvents(refresh: true) }
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(AppColors.Button.primary)
            .cornerRadius(8)
            Spacer()
        }
    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text(searchText.isEmpty ? "No events available" : "No events match your search")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
    
    var eventsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredEvents, id: \.id) { event in
                    EventCard(event: event)
                        .onTapGesture {
                            selectedEvent = event
                            showingEventDetail = true
                        }
                        .onAppear {
                            if let last = filteredEvents.last, event.id == last.id {
                                Task { await viewModel.loadEvents() }
                            }
                        }
                }
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding()
        }
        .refreshable {
            Task { await viewModel.loadEvents(refresh: true) }
        }
    }
}

// MARK: - Supporting Views
private struct FilterButton: View {
    let filter: EventFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(filter.title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.Button.primary : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Preview
#Preview {
    EventsView(isModal: false)
        .environmentObject(MenuState())
}


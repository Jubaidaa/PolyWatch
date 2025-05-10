import SwiftUI

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let location: String
    let description: String
}

class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    
    func fetchEvents() {
        isLoading = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.events = [
                Event(
                    title: "Local Town Hall",
                    date: Date().addingTimeInterval(86400),
                    location: "City Hall",
                    description: "Discussion about local policies"
                ),
                Event(
                    title: "Community Meeting",
                    date: Date().addingTimeInterval(172800),
                    location: "Community Center",
                    description: "Open forum for community concerns"
                )
            ]
            self.isLoading = false
        }
    }
}

struct EventRow: View {
    let event: Event
    
<<<<<<< Updated upstream
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
=======
    let isModal: Bool
    let onLogoTap: () -> Void
>>>>>>> Stashed changes
    
    var body: some View {
<<<<<<< Updated upstream
        VStack(alignment: .leading, spacing: Constants.Padding.standard / 2) {
            Text(event.title)
                .font(.headline)
            
            HStack {
                Image(systemName: "calendar")
                Text(dateFormatter.string(from: event.date))
                    .font(.subheadline)
            }
            .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "location")
                Text(event.location)
                    .font(.subheadline)
            }
            .foregroundColor(.gray)
            
            Text(event.description)
                .font(.body)
                .padding(.top, 4)
        }
        .padding(.vertical, Constants.Padding.standard)
    }
}

struct EventsListView: View {
    @StateObject private var viewModel = EventsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AppColors.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopBarView(
                    onMenuTap: {},
                    onLogoTap: { presentationMode.wrappedValue.dismiss() },
                    onSearchTap: {}
                )
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading events...")
                    Spacer()
                } else if viewModel.events.isEmpty {
                    Spacer()
                    Text("No events available")
                        .font(.headline)
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.events) { event in
                            EventRow(event: event)
=======
        ZStack {
            AppColors.white.ignoresSafeArea()
            VStack(spacing: 0) {
                TopBarView(
                    onMenuTap: {
                        withAnimation {
                            menuState.isShowing = true
>>>>>>> Stashed changes
                        }
                    },
                    onLogoTap: onLogoTap,
                    onSearchTap: {}
                )
                searchAndFilterBar
                content
            }
        }
        .navigationBarHidden(true)
        .navigationTitle("Events")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isModal {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Exit") {
                        menuState.showingEvents = false
                    }
                    .listStyle(.plain)
                }
            }
<<<<<<< Updated upstream
        }
        .navigationBarHidden(true)
=======
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
>>>>>>> Stashed changes
        .onAppear {
            viewModel.fetchEvents()
        }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
    }
<<<<<<< Updated upstream
} 
=======
    
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
    EventsView(isModal: false, onLogoTap: {})
        .environmentObject(MenuState())
}

>>>>>>> Stashed changes

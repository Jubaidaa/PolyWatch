// EventsView.swift
// Lists events with a search bar, filter bar, and paginated/model-backed data

import SwiftUI

struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var menuState: MenuState
    
    // Whether this view is shown modally or in a navigation stack
    let isModal: Bool
    
    // State for the view
    @State private var searchText = ""
    @State private var selectedFilter: EventFilter = .all
    @State private var showingEventDetail = false
    @State private var selectedEvent: Event?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Bar
                    TopBarView(
                        onMenuTap: {
                            withAnimation {
                                menuState.isShowing = true
                            }
                        },
                        onLogoTap: {
                            withAnimation {
                                if isModal {
                                    menuState.showingEvents = false
                                }
                                menuState.closeAllOverlays()
                                NotificationCenter.default.post(
                                    name: Notification.Name("returnToMainView"),
                                    object: nil
                                )
                            }
                        },
                        onSearchTap: {}
                    )
                    
                    // Search and filter bar
                    searchBar
                    filterBar
                    
                    // Main content
                    content
                }
                
                // Sidebar and overlay handling
                if menuState.isShowing {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { 
                            withAnimation { 
                                menuState.isShowing = false 
                            } 
                        }
                        .zIndex(1)
                    
                    VStack {
                        SidebarMenuContent(onLogoTap: {
                            withAnimation {
                                menuState.closeAllOverlays()
                                NotificationCenter.default.post(
                                    name: Notification.Name("returnToMainView"), 
                                    object: nil
                                )
                            }
                        })
                        .environmentObject(menuState)
                        .frame(maxWidth: 320)
                        .padding(.top, 60)
                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                    .zIndex(2)
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
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
            .onAppear {
                Task {
                    await viewModel.loadEvents()
                }
            }
            // Use the notification system for consistent navigation
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("returnToMainView"))) { _ in
                if isModal {
                    menuState.showingEvents = false
                }
            }
        }
    }
    
    // MARK: – Subviews
    
    private var searchBar: some View {
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
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(EventFilter.allCases) { filter in
                    FilterButton(
                        filter: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.events.isEmpty {
            // Initial loading state
            VStack {
                Spacer()
                ProgressView("Loading events…")
                Spacer()
            }
        } else if let error = viewModel.error {
            // Error state
            errorView(error)
        } else if filteredEvents.isEmpty {
            // Empty state
            VStack {
                Spacer()
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text(searchText.isEmpty ? "No events available" : "No events match your search")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
            }
        } else {
            // List of events
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredEvents) { event in
                        EventCard(event: event)
                            .onTapGesture {
                                selectedEvent = event
                                showingEventDetail = true
                            }
                    }
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
            .refreshable {
                await viewModel.loadEvents(refresh: true)
            }
        }
    }
    
    // MARK: – Helpers
    
    private var filteredEvents: [Event] {
        viewModel
            .getFilteredEvents(filter: selectedFilter)
            .filter { event in
                searchText.isEmpty ||
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.location.localizedCaseInsensitiveContains(searchText) ||
                event.description.localizedCaseInsensitiveContains(searchText)
            }
    }
    
    /// Renders when `viewModel.error` is non-nil.
    private func errorView(_ error: Error) -> some View {
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
                Task { await viewModel.loadEvents() }
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(AppColors.blue)
            .cornerRadius(8)
            Spacer()
        }
    }
}

// MARK: – Supporting Views

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
                .background(isSelected ? AppColors.blue : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView(isModal: false)
            .environmentObject(MenuState())
    }
}


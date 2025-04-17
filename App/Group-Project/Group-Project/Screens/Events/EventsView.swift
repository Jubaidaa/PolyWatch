import SwiftUI

struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()
    @EnvironmentObject private var menuState: MenuState
    var isModal: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                            }
                        }
                        .listStyle(.plain)
                    }
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
        }
        .onAppear {
            viewModel.fetchEvents()
        }
    }
}

#Preview {
    EventsView()
        .environmentObject(MenuState())
} 
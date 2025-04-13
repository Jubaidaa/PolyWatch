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
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
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
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchEvents()
        }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
    }
} 
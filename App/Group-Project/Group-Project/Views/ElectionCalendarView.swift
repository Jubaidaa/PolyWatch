import SwiftUI
import CoreLocation

struct ElectionEvent: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let description: String
    let type: String
    let city: String
    let details: ElectionDetails
}

struct ElectionDetails {
    let registrationDeadline: Date
    let votingMethod: [String] // ["In-person", "Mail-in", "Early Voting"]
    let pollingHours: String
    let requirements: [String]
    let website: String
    let locations: [VotingLocation]
    let importantDates: [ImportantDate]
}

struct VotingLocation: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let type: String // "Polling Place", "Drop Box", "Early Voting Center"
    let hours: String
    let accessibility: Bool
}

struct ImportantDate: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let description: String
}

class ElectionCalendarViewModel: NSObject, ObservableObject {
    @Published var events: [ElectionEvent] = []
    @Published var selectedDate: Date = Date()
    @Published var userLocation: String = "Loading..."
    @Published var locationError: String?
    private let locationManager = CLLocationManager()
    
    var filteredEvents: [ElectionEvent] {
        events.filter { event in
            Calendar.current.isDate(event.date, equalTo: selectedDate, toGranularity: .month)
        }.sorted { $0.date < $1.date }
    }
    
    override init() {
        super.init()
        setupLocationManager()
        loadAllElectionEvents()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000 // Update when user moves 1km
        
        // Check authorization status
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationError = "Location access is required to show local elections. Please enable location services in Settings."
            userLocation = "Location Disabled"
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func moveMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    func loadAllElectionEvents() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        var allEvents: [ElectionEvent] = []
        
        // Add state elections
        allEvents.append(contentsOf: stateElections(for: currentYear))
        
        // Add city-specific elections
        for city in CaliforniaCities.allCities {
            allEvents.append(contentsOf: cityElections(for: city, in: currentYear))
        }
        
        // Update events
        events = allEvents.sorted { $0.date < $1.date }
    }
    
    private func stateElections(for year: Int) -> [ElectionEvent] {
        let calendar = Calendar.current
        return [
            ElectionEvent(
                title: "California Primary Election",
                date: calendar.date(from: DateComponents(year: year, month: 3, day: 5)) ?? Date(),
                description: "Super Tuesday - Presidential Primary Election",
                type: "State",
                city: "California",
                details: ElectionDetails(
                    registrationDeadline: calendar.date(from: DateComponents(year: year, month: 2, day: 20)) ?? Date(),
                    votingMethod: ["In-person", "Mail-in", "Early Voting"],
                    pollingHours: "7:00 AM - 8:00 PM",
                    requirements: ["Must be registered to vote", "Must be 18 years or older", "Must be a California resident"],
                    website: "https://www.sos.ca.gov/elections",
                    locations: [],
                    importantDates: [
                        ImportantDate(
                            title: "Registration Deadline",
                            date: calendar.date(from: DateComponents(year: year, month: 2, day: 20)) ?? Date(),
                            description: "Last day to register for the primary election"
                        )
                    ]
                )
            ),
            ElectionEvent(
                title: "California General Election",
                date: calendar.date(from: DateComponents(year: year, month: 11, day: 5)) ?? Date(),
                description: "Presidential General Election",
                type: "State",
                city: "California",
                details: ElectionDetails(
                    registrationDeadline: calendar.date(from: DateComponents(year: year, month: 10, day: 21)) ?? Date(),
                    votingMethod: ["In-person", "Mail-in", "Early Voting"],
                    pollingHours: "7:00 AM - 8:00 PM",
                    requirements: ["Must be registered to vote", "Must be 18 years or older", "Must be a California resident"],
                    website: "https://www.sos.ca.gov/elections",
                    locations: [],
                    importantDates: [
                        ImportantDate(
                            title: "Registration Deadline",
                            date: calendar.date(from: DateComponents(year: year, month: 10, day: 21)) ?? Date(),
                            description: "Last day to register for the general election"
                        )
                    ]
                )
            )
        ]
    }
    
    private func cityElections(for city: String, in year: Int) -> [ElectionEvent] {
        let calendar = Calendar.current
        var events: [ElectionEvent] = []
        
        // Add city-specific elections
        switch city {
        case "San Francisco":
            events.append(
                ElectionEvent(
                    title: "SF Municipal Election",
                    date: calendar.date(from: DateComponents(year: year, month: 6, day: 15)) ?? Date(),
                    description: "City Council and Local Measures",
                    type: "Local",
                    city: "San Francisco",
                    details: ElectionDetails(
                        registrationDeadline: calendar.date(from: DateComponents(year: year, month: 5, day: 31)) ?? Date(),
                        votingMethod: ["In-person", "Mail-in", "Early Voting"],
                        pollingHours: "7:00 AM - 8:00 PM",
                        requirements: ["Must be registered to vote", "Must be 18 years or older", "Must be a San Francisco resident"],
                        website: "https://sfelections.sfgov.org",
                        locations: [
                            VotingLocation(
                                name: "San Francisco City Hall",
                                address: "1 Dr. Carlton B. Goodlett Place, San Francisco, CA 94102",
                                type: "Polling Place",
                                hours: "7:00 AM - 8:00 PM",
                                accessibility: true
                            )
                        ],
                        importantDates: [
                            ImportantDate(
                                title: "Registration Deadline",
                                date: calendar.date(from: DateComponents(year: year, month: 5, day: 31)) ?? Date(),
                                description: "Last day to register for the municipal election"
                            )
                        ]
                    )
                )
            )
            
        case "Oakland":
            events.append(
                ElectionEvent(
                    title: "Oakland City Council Election",
                    date: calendar.date(from: DateComponents(year: year, month: 6, day: 4)) ?? Date(),
                    description: "City Council and Local Measures",
                    type: "Local",
                    city: "Oakland",
                    details: ElectionDetails(
                        registrationDeadline: calendar.date(from: DateComponents(year: year, month: 5, day: 20)) ?? Date(),
                        votingMethod: ["In-person", "Mail-in", "Early Voting"],
                        pollingHours: "7:00 AM - 8:00 PM",
                        requirements: ["Must be registered to vote", "Must be 18 years or older", "Must be an Oakland resident"],
                        website: "https://www.oaklandca.gov/topics/elections",
                        locations: [
                            VotingLocation(
                                name: "Oakland City Hall",
                                address: "1 Frank H. Ogawa Plaza, Oakland, CA 94612",
                                type: "Polling Place",
                                hours: "7:00 AM - 8:00 PM",
                                accessibility: true
                            )
                        ],
                        importantDates: [
                            ImportantDate(
                                title: "Registration Deadline",
                                date: calendar.date(from: DateComponents(year: year, month: 5, day: 20)) ?? Date(),
                                description: "Last day to register for the municipal election"
                            )
                        ]
                    )
                )
            )
            
        // Add more cities as needed...
        default:
            break
        }
        
        return events
    }
}

extension ElectionCalendarViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.locationError = "Error getting location: \(error.localizedDescription)"
                    self?.userLocation = "Location Error"
                }
                return
            }
            
            guard let placemark = placemarks?.first,
                  let city = placemark.locality else {
                DispatchQueue.main.async {
                    self?.locationError = "Could not determine city"
                    self?.userLocation = "Unknown Location"
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.userLocation = city
                self?.locationError = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = "Location error: \(error.localizedDescription)"
            self.userLocation = "Location Error"
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
            manager.startUpdatingLocation()
        case .denied, .restricted:
            locationError = "Location access is required to show local elections. Please enable location services in Settings."
            userLocation = "Location Disabled"
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}

struct ElectionCalendarView: View {
    @StateObject private var viewModel = ElectionCalendarViewModel()
    @EnvironmentObject private var menuState: MenuState
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Location and calendar header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.userLocation)
                            .font(.headline)
                            .foregroundColor(.red)
                        if let error = viewModel.locationError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    Spacer()
                }
                .padding()
                
                // Month navigation
                HStack {
                    Button(action: {
                        withAnimation {
                            viewModel.moveMonth(by: -1)
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                    
                    Text(viewModel.selectedDate.formatted(.dateTime.month(.wide).year()))
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        withAnimation {
                            viewModel.moveMonth(by: 1)
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                // Today button
                Button(action: {
                    withAnimation {
                        viewModel.selectedDate = Date()
                    }
                }) {
                    Text("Today")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.bottom)
                
                // Calendar grid
                CalendarGrid(selectedDate: $viewModel.selectedDate, events: viewModel.filteredEvents, userLocation: viewModel.userLocation)
                
                // Events list
                VStack(alignment: .leading, spacing: 12) {
                    if !viewModel.filteredEvents.isEmpty {
                        Text("Elections This Month")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.filteredEvents) { event in
                                    ElectionEventCard(event: event, userLocation: viewModel.userLocation)
                                }
                            }
                            .padding()
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No Elections This Month")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    withAnimation {
                        menuState.showingCalendar = false
                    }
                }
            )
        }
    }
}

struct CalendarGrid: View {
    @Binding var selectedDate: Date
    let events: [ElectionEvent]
    let userLocation: String
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 8) {
            // Days of week header
            HStack {
                ForEach(daysInWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar days
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, equalTo: selectedDate, toGranularity: .day),
                            events: events.filter { calendar.isDate($0.date, equalTo: date, toGranularity: .day) },
                            userLocation: userLocation,
                            isToday: calendar.isDateInToday(date),
                            action: { selectedDate = date }
                        )
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
    }
    
    private func daysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: selectedDate)!
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)!.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: interval.start) {
                days.append(date)
            }
        }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let events: [ElectionEvent]
    let userLocation: String
    let isToday: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : (isToday ? .red : .primary))
                
                if !events.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(events.prefix(3)) { event in
                            Circle()
                                .fill(eventColor(for: event))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected {
                        Circle().fill(Color.red)
                    } else if isToday {
                        Circle().stroke(Color.red, lineWidth: 1)
                    }
                }
            )
        }
    }
    
    private func eventColor(for event: ElectionEvent) -> Color {
        if event.type == "State" {
            return .blue
        } else if event.city == userLocation {
            return .orange
        } else {
            return .green
        }
    }
}

struct ElectionEventCard: View {
    let event: ElectionEvent
    let userLocation: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header section
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.headline)
                        Text(event.date.formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(event.type)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(eventColor.opacity(0.1))
                            )
                            .foregroundColor(eventColor)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Divider()
                    .padding(.vertical, 8)
                
                // Description
                Text(event.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                // Important Dates Section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Important Dates", systemImage: "calendar.badge.clock")
                        .font(.headline)
                        .foregroundColor(eventColor)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        DateRow(
                            title: "Registration Deadline",
                            date: event.details.registrationDeadline,
                            icon: "person.badge.clock"
                        )
                        
                        ForEach(event.details.importantDates) { date in
                            DateRow(
                                title: date.title,
                                date: date.date,
                                description: date.description,
                                icon: "calendar"
                            )
                        }
                    }
                    .padding(.leading)
                }
                
                // Voting Methods Section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Voting Methods", systemImage: "checkmark.circle")
                        .font(.headline)
                        .foregroundColor(eventColor)
                        .padding(.top, 8)
                    
                    ForEach(event.details.votingMethod, id: \.self) { method in
                        HStack {
                            Image(systemName: votingMethodIcon(for: method))
                                .foregroundColor(eventColor)
                            Text(method)
                                .font(.subheadline)
                        }
                    }
                    .padding(.leading)
                }
                
                // Voting Locations Section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Voting Locations", systemImage: "mappin.and.ellipse")
                        .font(.headline)
                        .foregroundColor(eventColor)
                        .padding(.top, 8)
                    
                    ForEach(event.details.locations) { location in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: locationTypeIcon(for: location.type))
                                    .foregroundColor(eventColor)
                                Text(location.name)
                                    .font(.subheadline.bold())
                                if location.accessibility {
                                    Image(systemName: "figure.roll")
                                        .foregroundColor(.blue)
                                }
                            }
                            Text(location.address)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(location.hours)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading)
                    }
                }
                
                // Requirements Section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Requirements", systemImage: "list.clipboard")
                        .font(.headline)
                        .foregroundColor(eventColor)
                        .padding(.top, 8)
                    
                    ForEach(event.details.requirements, id: \.self) { requirement in
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(eventColor)
                            Text(requirement)
                                .font(.subheadline)
                        }
                    }
                    .padding(.leading)
                }
                
                // Website Link
                Link(destination: URL(string: event.details.website)!) {
                    HStack {
                        Text("Official Election Website")
                        Image(systemName: "arrow.up.right.square")
                    }
                    .font(.subheadline)
                    .foregroundColor(eventColor)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var eventColor: Color {
        if event.type == "State" {
            return .blue
        } else if event.city == userLocation {
            return .orange
        } else {
            return .green
        }
    }
    
    private func votingMethodIcon(for method: String) -> String {
        switch method {
        case "In-person": return "person.fill"
        case "Mail-in": return "envelope.fill"
        case "Early Voting": return "calendar.badge.clock"
        default: return "checkmark.circle"
        }
    }
    
    private func locationTypeIcon(for type: String) -> String {
        switch type {
        case "Polling Place": return "building.2"
        case "Drop Box": return "mailbox"
        case "Early Voting Center": return "building"
        default: return "mappin"
        }
    }
}

struct DateRow: View {
    let title: String
    let date: Date
    let description: String?
    let icon: String
    
    init(title: String, date: Date, description: String? = nil, icon: String) {
        self.title = title
        self.date = date
        self.description = description
        self.icon = icon
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                Text(title)
                    .font(.subheadline.bold())
            }
            Text(date.formatted(date: .long, time: .omitted))
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let description = description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CaliforniaCities {
    static let allCities = [
        "San Francisco",
        "Oakland",
        "San Jose",
        "Berkeley",
        "Palo Alto",
        "Mountain View",
        "Santa Clara",
        "Fremont",
        "Hayward",
        "Richmond"
    ]
}

#Preview {
    ElectionCalendarView()
} 
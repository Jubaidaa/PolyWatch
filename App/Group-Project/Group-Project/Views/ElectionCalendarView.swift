import SwiftUI
import CoreLocation

// MARK: - Models

struct CalendarEventItem: Identifiable {
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

// MARK: - ViewModel

class ElectionCalendarViewModel: NSObject, ObservableObject {
    @Published var events: [CalendarEventItem] = []
    @Published var selectedDate: Date = Date()
    @Published var userLocation: String = "Loading..."
    @Published var locationError: String?
    private let locationManager = CLLocationManager()

    var filteredEvents: [CalendarEventItem] {
        events
            .filter { Calendar.current.isDate($0.date, equalTo: selectedDate, toGranularity: .month) }
            .sorted { $0.date < $1.date }
    }

    override init() {
        super.init()
        setupLocationManager()
        loadAllElectionEvents()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000

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
        let year = calendar.component(.year, from: Date())
        var all: [CalendarEventItem] = []
        all += stateElections(for: year)
        for city in CaliforniaCities.allCities {
            all += cityElections(for: city, in: year)
        }
        events = all.sorted { $0.date < $1.date }
    }

    private func stateElections(for year: Int) -> [CalendarEventItem] {
        let cal = Calendar.current
        return [
            CalendarEventItem(
                title: "California Primary Election",
                date: cal.date(from: DateComponents(year: year, month: 3, day: 5))!,
                description: "Super Tuesday - Presidential Primary",
                type: "State",
                city: "California",
                details: ElectionDetails(
                    registrationDeadline: cal.date(from: DateComponents(year: year, month: 2, day: 20))!,
                    votingMethod: ["In-person", "Mail-in", "Early Voting"],
                    pollingHours: "7:00 AM – 8:00 PM",
                    requirements: ["Registered to vote", "18+ years", "California resident"],
                    website: "https://www.sos.ca.gov/elections",
                    locations: [],
                    importantDates: [
                        ImportantDate(
                            title: "Registration Deadline",
                            date: cal.date(from: DateComponents(year: year, month: 2, day: 20))!,
                            description: "Last day to register"
                        )
                    ]
                )
            ),
            CalendarEventItem(
                title: "California General Election",
                date: cal.date(from: DateComponents(year: year, month: 11, day: 5))!,
                description: "Presidential General Election",
                type: "State",
                city: "California",
                details: ElectionDetails(
                    registrationDeadline: cal.date(from: DateComponents(year: year, month: 10, day: 21))!,
                    votingMethod: ["In-person", "Mail-in", "Early Voting"],
                    pollingHours: "7:00 AM – 8:00 PM",
                    requirements: ["Registered to vote", "18+ years", "California resident"],
                    website: "https://www.sos.ca.gov/elections",
                    locations: [],
                    importantDates: [
                        ImportantDate(
                            title: "Registration Deadline",
                            date: cal.date(from: DateComponents(year: year, month: 10, day: 21))!,
                            description: "Last day to register"
                        )
                    ]
                )
            )
        ]
    }

    private func cityElections(for city: String, in year: Int) -> [CalendarEventItem] {
        let cal = Calendar.current
        switch city {
        case "San Francisco":
            return [
                CalendarEventItem(
                    title: "SF Municipal Election",
                    date: cal.date(from: DateComponents(year: year, month: 6, day: 15))!,
                    description: "City Council & Local Measures",
                    type: "Local",
                    city: "San Francisco",
                    details: ElectionDetails(
                        registrationDeadline: cal.date(from: DateComponents(year: year, month: 5, day: 31))!,
                        votingMethod: ["In-person", "Mail-in", "Early Voting"],
                        pollingHours: "7:00 AM – 8:00 PM",
                        requirements: ["Registered to vote", "18+ years", "SF resident"],
                        website: "https://sfelections.sfgov.org",
                        locations: [
                            VotingLocation(
                                name: "SF City Hall",
                                address: "1 Dr. Carlton B. Goodlett Place",
                                type: "Polling Place",
                                hours: "7:00 AM – 8:00 PM",
                                accessibility: true
                            )
                        ],
                        importantDates: [
                            ImportantDate(
                                title: "Registration Deadline",
                                date: cal.date(from: DateComponents(year: year, month: 5, day: 31))!,
                                description: "Last day to register"
                            )
                        ]
                    )
                )
            ]
        case "Oakland":
            return [
                CalendarEventItem(
                    title: "Oakland City Council Election",
                    date: cal.date(from: DateComponents(year: year, month: 6, day: 4))!,
                    description: "City Council & Measures",
                    type: "Local",
                    city: "Oakland",
                    details: ElectionDetails(
                        registrationDeadline: cal.date(from: DateComponents(year: year, month: 5, day: 20))!,
                        votingMethod: ["In-person", "Mail-in", "Early Voting"],
                        pollingHours: "7:00 AM – 8:00 PM",
                        requirements: ["Registered to vote", "18+ years", "Oakland resident"],
                        website: "https://www.oaklandca.gov/topics/elections",
                        locations: [
                            VotingLocation(
                                name: "Oakland City Hall",
                                address: "1 Frank H. Ogawa Plaza",
                                type: "Polling Place",
                                hours: "7:00 AM – 8:00 PM",
                                accessibility: true
                            )
                        ],
                        importantDates: [
                            ImportantDate(
                                title: "Registration Deadline",
                                date: cal.date(from: DateComponents(year: year, month: 5, day: 20))!,
                                description: "Last day to register"
                            )
                        ]
                    )
                )
            ]
        default:
            return []
        }
    }
}

extension ElectionCalendarViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        CLGeocoder().reverseGeocodeLocation(loc) { [weak self] places, err in
            DispatchQueue.main.async {
                if let err = err {
                    self?.locationError = "Error: \(err.localizedDescription)"
                    self?.userLocation = "Location Error"
                } else if let city = places?.first?.locality {
                    self?.userLocation = city
                    self?.locationError = nil
                } else {
                    self?.locationError = "Could not determine city"
                    self?.userLocation = "Unknown"
                }
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
            locationError = "Location access is required..."
            userLocation = "Location Disabled"
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}

// MARK: - View

struct ElectionCalendarView: View {
    @StateObject private var viewModel = ElectionCalendarViewModel()
    @EnvironmentObject private var menuState: MenuState
    let onLogoTap: () -> Void

    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    TopBarView(
                        onMenuTap: { withAnimation { menuState.isShowing = true } },
                        onLogoTap: onLogoTap,
                        onSearchTap: {}
                    )
                    // TODO: Insert your calendar header, grid, etc. here
                }

                if menuState.isShowing {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { menuState.isShowing = false } }
                        .zIndex(1)
                }
                if menuState.isShowing {
                    VStack {
                        SidebarMenuContent(onLogoTap: onLogoTap)
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
        }
    }
}

// MARK: - CalendarGrid & Cells

struct CalendarGrid: View {
    @Binding var selectedDate: Date
    let events: [CalendarEventItem]
    let userLocation: String

    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(daysOfWeek, id: \.self) {
                    Text($0).font(.caption).foregroundColor(.gray).frame(maxWidth: .infinity)
                }
            }

            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 8) {
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
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
        .padding()
    }

    private func daysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: selectedDate)!
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let totalDays = calendar.range(of: .day, in: .month, for: selectedDate)!.count

        var array: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for d in 1...totalDays {
            if let dt = calendar.date(byAdding: .day, value: d-1, to: interval.start) {
                array.append(dt)
            }
        }
        while array.count % 7 != 0 { array.append(nil) }
        return array
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let events: [CalendarEventItem]
    let userLocation: String
    let isToday: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size:16))
                    .foregroundColor(isSelected ? .white : (isToday ? .red : .primary))
                if !events.isEmpty {
                    HStack(spacing:2) {
                        ForEach(events.prefix(3)) { _ in
                            Circle().frame(width:4, height:4).foregroundColor(eventColor)
                        }
                    }
                }
            }
            .frame(height:40).frame(maxWidth:.infinity)
            .background(
                Group {
                    if isSelected {
                        Circle().fill(Color.red)
                    } else if isToday {
                        Circle().stroke(Color.red, lineWidth:1)
                    }
                }
            )
        }
    }

    private var eventColor: Color {
        guard let first = events.first else { return .green }
        if first.type == "State" { return .blue }
        else if first.city == userLocation { return .orange }
        else { return .green }
    }
}

// MARK: - Utility Views

struct DateRow: View {
    let title: String
    let date: Date
    let description: String?
    let icon: String

    init(title: String, date: Date, description: String? = nil, icon: String) {
        self.title = title; self.date = date; self.description = description; self.icon = icon
    }

    var body: some View {
        VStack(alignment:.leading, spacing:4) {
            HStack {
                Image(systemName: icon)
                Text(title).font(.subheadline.bold())
            }
            Text(date.formatted(date:.long, time:.omitted)).font(.subheadline).foregroundColor(.secondary)
            if let desc = description {
                Text(desc).font(.caption).foregroundColor(.secondary)
            }
        }
    }
}

struct CaliforniaCities {
    static let allCities = [
        "San Francisco","Oakland","San Jose","Berkeley","Palo Alto",
        "Mountain View","Santa Clara","Fremont","Hayward","Richmond"
    ]
}

// MARK: - Preview

#Preview {
    ElectionCalendarView(onLogoTap: {})
        .environmentObject(MenuState())
}


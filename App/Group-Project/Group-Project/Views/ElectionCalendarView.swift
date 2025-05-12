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
        all += nationalElections(for: year)
        all += stateElections(for: year)
        for city in CaliforniaCities.allCities {
            all += cityElections(for: city, in: year)
        }
        events = all.sorted { $0.date < $1.date }
    }

    private func nationalElections(for year: Int) -> [CalendarEventItem] {
        let cal = Calendar.current
        return [
            CalendarEventItem(
                title: "US Presidential Election",
                date: cal.date(from: DateComponents(year: year, month: 11, day: 5))!,
                description: "Election for President of the United States",
                type: "National",
                city: "United States",
                details: ElectionDetails(
                    registrationDeadline: cal.date(from: DateComponents(year: year, month: 10, day: 15))!,
                    votingMethod: ["In-person", "Mail-in", "Early Voting"],
                    pollingHours: "Varies by state",
                    requirements: ["US Citizen", "18+ years", "Registered voter"],
                    website: "https://www.usa.gov/voting",
                    locations: [],
                    importantDates: [
                        ImportantDate(
                            title: "Early Voting Begins",
                            date: cal.date(from: DateComponents(year: year, month: 10, day: 19))!,
                            description: "Early voting begins in many states"
                        ),
                        ImportantDate(
                            title: "Election Day",
                            date: cal.date(from: DateComponents(year: year, month: 11, day: 5))!,
                            description: "National election day"
                        )
                    ]
                )
            ),
            CalendarEventItem(
                title: "US Congressional Midterm Elections",
                date: cal.date(from: DateComponents(year: year + 2, month: 11, day: 3))!,
                description: "Elections for the US House and Senate",
                type: "National",
                city: "United States",
                details: ElectionDetails(
                    registrationDeadline: cal.date(from: DateComponents(year: year + 2, month: 10, day: 15))!,
                    votingMethod: ["In-person", "Mail-in", "Early Voting"],
                    pollingHours: "Varies by state",
                    requirements: ["US Citizen", "18+ years", "Registered voter"],
                    website: "https://www.usa.gov/voting",
                    locations: [],
                    importantDates: [
                        ImportantDate(
                            title: "Early Voting Begins",
                            date: cal.date(from: DateComponents(year: year + 2, month: 10, day: 19))!,
                            description: "Early voting begins in many states"
                        )
                    ]
                )
            )
        ]
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
                        ),
                        ImportantDate(
                            title: "Mail Ballot Sent",
                            date: cal.date(from: DateComponents(year: year, month: 2, day: 5))!,
                            description: "Vote-by-mail ballots sent to voters"
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
                        ),
                        ImportantDate(
                            title: "Mail Ballot Sent",
                            date: cal.date(from: DateComponents(year: year, month: 10, day: 8))!,
                            description: "Vote-by-mail ballots sent to voters"
                        ),
                        ImportantDate(
                            title: "Early Voting Begins",
                            date: cal.date(from: DateComponents(year: year, month: 10, day: 26))!,
                            description: "Early voting period begins"
                        )
                    ]
                )
            ),
            CalendarEventItem(
                title: "California State Propositions",
                date: cal.date(from: DateComponents(year: year, month: 11, day: 5))!,
                description: "Statewide ballot measures",
                type: "State",
                city: "California",
                details: ElectionDetails(
                    registrationDeadline: cal.date(from: DateComponents(year: year, month: 10, day: 21))!,
                    votingMethod: ["In-person", "Mail-in", "Early Voting"],
                    pollingHours: "7:00 AM – 8:00 PM",
                    requirements: ["Registered to vote", "18+ years", "California resident"],
                    website: "https://voterguide.sos.ca.gov/",
                    locations: [],
                    importantDates: [
                        ImportantDate(
                            title: "Voter Guide Mailed",
                            date: cal.date(from: DateComponents(year: year, month: 9, day: 25))!,
                            description: "Official voter information guide mailed"
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
                            ),
                            VotingLocation(
                                name: "Bill Graham Civic Auditorium",
                                address: "99 Grove St, San Francisco",
                                type: "Voting Center",
                                hours: "8:00 AM – 5:00 PM",
                                accessibility: true
                            )
                        ],
                        importantDates: [
                            ImportantDate(
                                title: "Registration Deadline",
                                date: cal.date(from: DateComponents(year: year, month: 5, day: 31))!,
                                description: "Last day to register"
                            ),
                            ImportantDate(
                                title: "Vote-by-Mail Begins",
                                date: cal.date(from: DateComponents(year: year, month: 5, day: 15))!,
                                description: "Ballots mailed to all registered voters"
                            )
                        ]
                    )
                ),
                CalendarEventItem(
                    title: "SF School Board Election",
                    date: cal.date(from: DateComponents(year: year, month: 11, day: 5))!,
                    description: "School Board Members & Education Measures",
                    type: "Local",
                    city: "San Francisco",
                    details: ElectionDetails(
                        registrationDeadline: cal.date(from: DateComponents(year: year, month: 10, day: 21))!,
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
                                date: cal.date(from: DateComponents(year: year, month: 10, day: 21))!,
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
                            ),
                            VotingLocation(
                                name: "Alameda County Courthouse",
                                address: "1225 Fallon St, Oakland",
                                type: "Voting Center",
                                hours: "8:00 AM – 5:00 PM",
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
                ),
                CalendarEventItem(
                    title: "Oakland Mayoral Election",
                    date: cal.date(from: DateComponents(year: year, month: 11, day: 5))!,
                    description: "Election for Mayor of Oakland",
                    type: "Local",
                    city: "Oakland",
                    details: ElectionDetails(
                        registrationDeadline: cal.date(from: DateComponents(year: year, month: 10, day: 21))!,
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
                                date: cal.date(from: DateComponents(year: year, month: 10, day: 21))!,
                                description: "Last day to register"
                            )
                        ]
                    )
                )
            ]
        case "San Jose":
            return [
                CalendarEventItem(
                    title: "San Jose City Council Election",
                    date: cal.date(from: DateComponents(year: year, month: 6, day: 7))!,
                    description: "City Council & Local Measures",
                    type: "Local",
                    city: "San Jose",
                    details: ElectionDetails(
                        registrationDeadline: cal.date(from: DateComponents(year: year, month: 5, day: 23))!,
                        votingMethod: ["In-person", "Mail-in", "Early Voting"],
                        pollingHours: "7:00 AM – 8:00 PM",
                        requirements: ["Registered to vote", "18+ years", "San Jose resident"],
                        website: "https://www.sanjoseca.gov/your-government/departments/city-clerk/elections",
                        locations: [
                            VotingLocation(
                                name: "San Jose City Hall",
                                address: "200 East Santa Clara St",
                                type: "Polling Place",
                                hours: "7:00 AM – 8:00 PM",
                                accessibility: true
                            )
                        ],
                        importantDates: [
                            ImportantDate(
                                title: "Registration Deadline",
                                date: cal.date(from: DateComponents(year: year, month: 5, day: 23))!,
                                description: "Last day to register"
                            )
                        ]
                    )
                )
            ]
        case "Berkeley":
            return [
                CalendarEventItem(
                    title: "Berkeley City Election",
                    date: cal.date(from: DateComponents(year: year, month: 11, day: 5))!,
                    description: "City Council & Local Measures",
                    type: "Local",
                    city: "Berkeley",
                    details: ElectionDetails(
                        registrationDeadline: cal.date(from: DateComponents(year: year, month: 10, day: 21))!,
                        votingMethod: ["In-person", "Mail-in", "Early Voting"],
                        pollingHours: "7:00 AM – 8:00 PM",
                        requirements: ["Registered to vote", "18+ years", "Berkeley resident"],
                        website: "https://www.cityofberkeley.info/Clerk/Elections/Elections.aspx",
                        locations: [
                            VotingLocation(
                                name: "Berkeley Civic Center",
                                address: "2180 Milvia St",
                                type: "Polling Place",
                                hours: "7:00 AM – 8:00 PM",
                                accessibility: true
                            )
                        ],
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
    var showTopBar: Bool = true

    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    if showTopBar {
                        TopBarView(
                            onMenuTap: { withAnimation { menuState.isShowing = true } },
                            onLogoTap: {
                                withAnimation {
                                    menuState.returnToMainView()
                                }
                            },
                            onSearchTap: {}
                        )
                    }
                    
                    // Calendar header
                    VStack(spacing: 8) {
                        Text("Election Calendar")
                            .font(.system(size: 28, weight: .bold))
                            .padding(.top, 8)
                        
                        HStack {
                            Button(action: { viewModel.moveMonth(by: -1) }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(AppColors.blue)
                                    .padding()
                            }
                            
                            Spacer()
                            
                            Text(viewModel.selectedDate.formatted(.dateTime.month(.wide).year()))
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: { viewModel.moveMonth(by: 1) }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppColors.blue)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Calendar grid
                    CalendarGrid(
                        selectedDate: $viewModel.selectedDate,
                        events: viewModel.filteredEvents,
                        userLocation: viewModel.userLocation
                    )
                    
                    // Events list for selected date
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if viewModel.filteredEvents.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "calendar.badge.exclamationmark")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No events scheduled for this date")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.filteredEvents) { event in
                                        ElectionEventCard(event: event)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }

                if menuState.isShowing {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { menuState.isShowing = false } }
                        .zIndex(1)
                }
                if menuState.isShowing {
                    VStack {
                        SidebarMenuContent(onLogoTap: {
                            withAnimation {
                                menuState.returnToMainView()
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button(action: {
                            withAnimation {
                                menuState.closeAllOverlays()
                            }
                        }) {
                            Text("PolyWatch")
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.red)
                        }
                        Button("Close") {
                            withAnimation {
                                menuState.showingCalendar = false
                            }
                        }
                        .foregroundColor(AppColors.blue)
                    }
                }
            }
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
                    .foregroundColor(isSelected ? .white : (isToday ? AppColors.red : .primary))
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
                        Circle().fill(AppColors.red)
                    } else if isToday {
                        Circle().stroke(AppColors.red, lineWidth:1)
                    }
                }
            )
        }
    }

    private var eventColor: Color {
        guard let first = events.first else { return .green }
        if first.type == "State" { return AppColors.blue }
        else if first.city == userLocation { return .orange }
        else { return .green }
    }
}

// MARK: - Event Card

struct ElectionEventCard: View {
    let event: CalendarEventItem
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(event.title)
                .font(.headline)
                .foregroundColor(.black)
            
            // Location and Time in a single row
            HStack(spacing: 16) {
                // Location
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                    Text(event.city)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 4)
                
                // Time
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text(event.date.formatted(.dateTime.hour().minute()))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Description
            Text(event.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            showingDetails = true
        }
        .sheet(isPresented: $showingDetails) {
            CalendarEventDetailView(event: event)
        }
    }
}

// MARK: - Event Detail View

struct CalendarEventDetailView: View {
    let event: CalendarEventItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 12) {
                            Label(event.city, systemImage: "mappin.circle.fill")
                                .foregroundColor(.secondary)
                            
                            Divider()
                                .frame(height: 16)
                            
                            Label(event.date.formatted(.dateTime.month().day().year()), systemImage: "calendar")
                                .foregroundColor(.secondary)
                        }
                        .font(.subheadline)
                    }
                    .padding(.bottom, 8)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        
                        Text(event.description)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Registration Deadline
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Registration Deadline")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.red)
                            Text(event.details.registrationDeadline.formatted(date: .long, time: .omitted))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Voting Methods
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Voting Methods")
                            .font(.headline)
                        
                        ForEach(event.details.votingMethod, id: \.self) { method in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                                Text(method)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Polling Hours
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Polling Hours")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text(event.details.pollingHours)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Requirements
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Requirements")
                            .font(.headline)
                        
                        ForEach(event.details.requirements, id: \.self) { requirement in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 6))
                                    .padding(.top, 6)
                                Text(requirement)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Important Dates
                    if !event.details.importantDates.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Important Dates")
                                .font(.headline)
                            
                            ForEach(event.details.importantDates) { date in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(date.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.orange)
                                        Text(date.date.formatted(date: .long, time: .omitted))
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                    }
                                    
                                    if !date.description.isEmpty {
                                        Text(date.description)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    // Voting Locations
                    if !event.details.locations.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Voting Locations")
                                .font(.headline)
                            
                            ForEach(event.details.locations) { location in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(location.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    HStack(alignment: .top) {
                                        Image(systemName: "mappin")
                                            .foregroundColor(.red)
                                            .frame(width: 20)
                                        Text(location.address)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(.blue)
                                            .frame(width: 20)
                                        Text(location.hours)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.gray)
                                            .frame(width: 20)
                                        Text(location.type)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if location.accessibility {
                                        HStack {
                                            Image(systemName: "figure.roll")
                                                .foregroundColor(.blue)
                                                .frame(width: 20)
                                            Text("Accessible")
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Website Link
                    Divider()
                    
                    Button(action: {
                        if let url = URL(string: event.details.website) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Visit Official Website")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
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
        "San Francisco", "Oakland", "San Jose", "Berkeley", "Palo Alto",
        "Mountain View", "Santa Clara", "Fremont", "Hayward", "Richmond",
        "Daly City", "South San Francisco", "San Mateo", "Redwood City", "Sunnyvale",
        "Cupertino", "Milpitas", "Alameda", "San Rafael", "Walnut Creek",
        "Concord", "Pleasanton", "Livermore", "Dublin", "San Ramon"
    ]
}

// MARK: - Preview

#Preview {
    ElectionCalendarView(onLogoTap: {})
        .environmentObject(MenuState())
}


import SwiftUI

struct UpcomingView: View {
    @StateObject private var viewModel = ElectionsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showVoterRegistration = false
    @State private var selectedView: ViewType = .list
    
    enum ViewType {
        case list
        case calendar
    }
    
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
                
                // View Type Picker
                Picker("View Type", selection: $selectedView) {
                    Text("List").tag(ViewType.list)
                    Text("Calendar").tag(ViewType.calendar)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading elections...")
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    VStack(spacing: Constants.Padding.standard) {
                        Text("😕")
                            .font(.system(size: 64))
                        Text(error.description)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            viewModel.fetchElections()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding()
                    Spacer()
                } else if viewModel.elections.isEmpty {
                    Spacer()
                    // Center Image
                    Image("vote")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.85)
                        .padding(.vertical, Constants.Padding.standard / 2)
                        .accessibilityLabel("Voting Information")
                    Spacer()
                } else {
                    if selectedView == .list {
                        ScrollView {
                            LazyVStack(spacing: Constants.Padding.standard) {
                                ForEach(viewModel.elections.sorted { election1, election2 in
                                    election1.electionDay < election2.electionDay
                                }) { election in
                                    ElectionCard(election: election, dateFormatter: viewModel.formatDate)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    } else {
                        CalendarView(elections: viewModel.elections, dateFormatter: viewModel.formatDate)
                    }
                    
                    Spacer(minLength: 16)
                }
                
                // Voter Action Buttons
                VStack(spacing: Constants.Padding.standard) {
                    Button(action: {
                        showVoterRegistration = true
                    }) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                            Text("Register to Vote")
                                .font(.headline)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.primary))
                    .accessibilityHint("Opens voter registration view")
                    
                    Button(action: {
                        if let url = URL(string: Constants.URLs.checkVoterStatus) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "person.text.rectangle.fill")
                                .font(.title2)
                            Text("Check Voter Status")
                                .font(.headline)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.secondary))
                    .accessibilityHint("Opens voter status check website")
                }
                .padding(.horizontal, Constants.Padding.large)
                .padding(.bottom, Constants.Padding.bottom)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showVoterRegistration) {
            VoterRegistrationView()
        }
        .onAppear {
            viewModel.fetchElections()
        }
    }
}

struct CalendarView: View {
    let elections: [Election]
    let dateFormatter: (String) -> String
    @State private var selectedDate: Date = Date()
    @State private var selectedElection: Election?
    
    private let calendar = Calendar.current
    private let dateFormatter2 = DateFormatter()
    private let minDate: Date
    private let maxDate: Date
    
    init(elections: [Election], dateFormatter: @escaping (String) -> String) {
        self.elections = elections
        self.dateFormatter = dateFormatter
        dateFormatter2.dateFormat = "yyyy-MM-dd"
        
        // Set date range restrictions
        let now = Date()
        self.minDate = Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now
        self.maxDate = Calendar.current.date(byAdding: .year, value: 1, to: now) ?? now
        
        // Find today's date string
        let today = dateFormatter2.string(from: now)
        
        // Initialize state properties
        var initialDate = now
        var initialElection: Election? = nil
        
        // First try to find an event for today
        if let todayElection = elections.first(where: { $0.electionDay == today }) {
            initialElection = todayElection
            if let date = dateFormatter2.date(from: today) {
                initialDate = date
            }
        } else {
            // If no event today, find the next upcoming event
            let sortedElections = elections.sorted { election1, election2 in
                election1.electionDay < election2.electionDay
            }
            
            if let nextElection = sortedElections.first(where: { election in
                guard let eventDate = dateFormatter2.date(from: election.electionDay) else { return false }
                return eventDate >= now
            }) {
                initialElection = nextElection
                if let date = dateFormatter2.date(from: nextElection.electionDay) {
                    initialDate = date
                }
            } else {
                // If no upcoming events, use the most recent one
                if let firstElection = sortedElections.first,
                   let date = dateFormatter2.date(from: firstElection.electionDay) {
                    initialElection = firstElection
                    initialDate = date
                }
            }
        }
        
        // Initialize the state properties
        _selectedDate = State(initialValue: initialDate)
        _selectedElection = State(initialValue: initialElection)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Calendar Header
            HStack {
                Button(action: { moveMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(canMoveMonth(by: -1) ? .primary : .gray)
                }
                .disabled(!canMoveMonth(by: -1))
                
                Text(monthYearString(from: selectedDate))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                
                Button(action: { moveMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(canMoveMonth(by: 1) ? .primary : .gray)
                }
                .disabled(!canMoveMonth(by: 1))
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                let days = daysInMonth()
                ForEach(0..<days.count, id: \.self) { index in
                    if let date = days[index] {
                        CalendarDayCell(date: date, hasEvent: hasEvent(on: date))
                            .onTapGesture {
                                if hasEvent(on: date) {
                                    selectedElection = electionForDate(date)
                                }
                            }
                    } else {
                        Color.clear
                    }
                }
            }
            .padding(.horizontal)
            
            // Selected Election Details
            if let election = selectedElection {
                ElectionCard(election: election, dateFormatter: dateFormatter)
                    .padding(.horizontal)
                    .padding(.top)
            }
            
            Spacer(minLength: 0)
        }
    }
    
    private func canMoveMonth(by value: Int) -> Bool {
        guard let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) else {
            return false
        }
        
        // Get the start of the month for comparison
        let newMonth = calendar.startOfMonth(for: newDate)
        let minMonth = calendar.startOfMonth(for: minDate)
        let maxMonth = calendar.startOfMonth(for: maxDate)
        
        return newMonth >= minMonth && newMonth <= maxMonth
    }
    
    private func moveMonth(by value: Int) {
        if canMoveMonth(by: value),
           let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // Pad the remaining days to complete the grid
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasEvent(on date: Date) -> Bool {
        let dateString = dateFormatter2.string(from: date)
        return elections.contains { election in
            election.electionDay == dateString
        }
    }
    
    private func electionForDate(_ date: Date) -> Election? {
        let dateString = dateFormatter2.string(from: date)
        return elections.first { election in
            election.electionDay == dateString
        }
    }
}

// Helper extension for Calendar
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

struct CalendarDayCell: View {
    let date: Date
    let hasEvent: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14))
            
            if hasEvent {
                Circle()
                    .fill(AppColors.Button.primary)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(hasEvent ? AppColors.Button.primary.opacity(0.1) : Color.clear)
        )
    }
}

struct ElectionCard: View {
    let election: Election
    let dateFormatter: (String) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(election.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(dateFormatter(election.electionDay))
                .font(.body)
                .foregroundColor(.gray)
            
            if let stateName = election.stateName {
                Text(stateName)
                    .font(.body)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Constants.Dimensions.cornerRadius)
                .fill(Color.white)
                .shadow(radius: 2)
        )
    }
}

struct UpcomingView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingView()
    }
} 
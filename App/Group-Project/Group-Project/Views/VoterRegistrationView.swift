import SwiftUI

struct VoterRegistrationView: View {
    @EnvironmentObject private var menuState: MenuState
    @State private var selectedSection: InfoSection = .registration
    @State private var showingDetailView = false
    @State private var selectedDetail: DetailInfo?
    
    enum InfoSection: String, CaseIterable {
        case registration = "Register"
        case requirements = "Require..."
        case deadlines = "Key Dates"
        case rights = "Rights"
        case resources = "Resources"
    }
    
    struct DetailInfo: Identifiable {
        let id = UUID()
        let title: String
        let content: [String]
        let links: [(title: String, url: String)]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Register to Vote")
                                .font(.system(size: 34, weight: .bold))
                            Text("California Voter Information")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top)
                        
                        // Section Picker
                        Picker("Section", selection: $selectedSection) {
                            ForEach(InfoSection.allCases, id: \.self) { section in
                                Text(section.rawValue)
                                    .font(.system(size: 13))
                                    .tag(section)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, Constants.Padding.standard)
                        
                        // Content based on selected section
                        switch selectedSection {
                        case .registration:
                            registrationSection
                        case .requirements:
                            requirementsSection
                        case .deadlines:
                            deadlinesSection
                        case .rights:
                            rightsSection
                        case .resources:
                            resourcesSection
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button(action: {
                            withAnimation {
                                menuState.closeAllOverlays()
                                #if DEBUG
                                print("🏠 VoterRegistrationView: PolyWatch button tapped - returning to home screen")
                                print("   menuState ID: \(menuState.id)")
                                #endif
                            }
                        }) {
                            Text("PolyWatch")
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.red)
                        }
                        
                        Button("Close") {
                            withAnimation {
                                menuState.showingVoterRegistration = false
                            }
                        }
                        .foregroundColor(AppColors.blue)
                    }
                }
            }
            .sheet(item: $selectedDetail) { detail in
                DetailView(detail: detail)
            }
        }
    }
    
    private var registrationSection: some View {
        VStack(spacing: 16) {
            InfoCard(
                title: "Register Online",
                description: "The fastest and easiest way to register to vote in California. Tap for step-by-step guide.",
                action: {
                    selectedDetail = DetailInfo(
                        title: "Online Registration Guide",
                        content: [
                            "Step 1: Gather Required Information",
                            "• California driver's license or ID card number",
                            "• Last 4 digits of Social Security number",
                            "• Date of birth",
                            "• Home address and mailing address",
                            "• Email address (optional but recommended)",
                            "",
                            "Step 2: Complete the Form",
                            "• Visit registertovote.ca.gov",
                            "• Fill out all required fields",
                            "• Review your information carefully",
                            "• Submit your application",
                            "",
                            "Step 3: Confirmation",
                            "• You'll receive a confirmation number",
                            "• Your county elections office will contact you",
                            "• Your Voter Notification Card will arrive in 4-6 weeks"
                        ],
                        links: [("Register Now", "https://registertovote.ca.gov/")]
                    )
                    showingDetailView = true
                },
                actionText: "View Guide",
                showsDetailIndicator: true
            )
            
            InfoCard(
                title: "Register by Mail",
                description: "Request a paper application or pick one up at your local library, post office, or DMV. Tap for detailed instructions.",
                action: {
                    selectedDetail = DetailInfo(
                        title: "Mail Registration Guide",
                        content: [
                            "Where to Get an Application:",
                            "• County elections office",
                            "• Public libraries",
                            "• Post offices",
                            "• DMV offices",
                            "• Government offices",
                            "",
                            "How to Complete:",
                            "1. Fill out the application completely",
                            "2. Sign and date the form",
                            "3. Mail it to your county elections office",
                            "",
                            "Processing Time:",
                            "• 1-3 weeks for processing",
                            "• Voter Notification Card arrives in 4-6 weeks",
                            "",
                            "Note: The form is available in 10 languages"
                        ],
                        links: [
                            ("Request Form", "https://www.sos.ca.gov/elections/voter-registration/nvra/national-voter-registration-act/voter-registration-cards"),
                            ("Find County Office", "https://www.sos.ca.gov/elections/voting-resources/county-elections-offices")
                        ]
                    )
                    showingDetailView = true
                },
                actionText: "View Instructions",
                showsDetailIndicator: true
            )
            
            InfoCard(
                title: "Same Day Registration",
                description: "Register and vote on the same day at any voting location. Tap to learn about the process.",
                action: {
                    selectedDetail = DetailInfo(
                        title: "Same Day Registration",
                        content: [
                            "What You Need to Know:",
                            "• Available at all voting locations",
                            "• Available during early voting and Election Day",
                            "• Bring valid ID and proof of residence",
                            "",
                            "Process:",
                            "1. Visit any voting location in your county",
                            "2. Complete voter registration form",
                            "3. Receive a provisional ballot",
                            "4. Vote and submit your ballot",
                            "",
                            "Ballot Counting:",
                            "• Your ballot will be counted after your registration is verified",
                            "• Track your ballot status online",
                            "",
                            "Acceptable ID Forms:",
                            "• CA driver's license/ID",
                            "• Passport",
                            "• Employee ID",
                            "• Student ID",
                            "• Military ID",
                            "• Tribal ID"
                        ],
                        links: [("Find Voting Location", "https://www.sos.ca.gov/elections/polling-place")]
                    )
                    showingDetailView = true
                },
                actionText: "Learn More",
                showsDetailIndicator: true
            )
            
            InfoCard(
                title: "Check Registration Status",
                description: "View your current registration status, polling place, and ballot information. Tap for detailed voter information.",
                action: {
                    selectedDetail = DetailInfo(
                        title: "Voter Information",
                        content: [
                            "What You Can Check:",
                            "• Registration status",
                            "• Party preference",
                            "• Voting precinct",
                            "• Polling place location",
                            "• Sample ballot availability",
                            "• Vote-by-mail status",
                            "",
                            "How to Update Information:",
                            "1. Re-register if you:",
                            "   • Move to a new address",
                            "   • Change your name",
                            "   • Want to change party preference",
                            "",
                            "Additional Features:",
                            "• View upcoming elections",
                            "• Check ballot status",
                            "• Find drop box locations",
                            "• Sign up for ballot tracking"
                        ],
                        links: [
                            ("Check Status", "https://voterstatus.sos.ca.gov/"),
                            ("Track Ballot", "https://california.ballottrax.net/voter/")
                        ]
                    )
                    showingDetailView = true
                },
                actionText: "Check Now",
                showsDetailIndicator: true
            )
        }
        .padding()
    }
    
    private var requirementsSection: some View {
        VStack(spacing: 16) {
            InfoCard(
                title: "Basic Requirements",
                description: "To register to vote in California, you must be:\n• A United States citizen\n• A resident of California\n• 18 years or older on Election Day\n• Not currently serving a state or federal prison term for a felony conviction\n• Not currently found mentally incompetent by a court",
                action: nil,
                actionText: nil
            )
            
            InfoCard(
                title: "Pre-Registration for Youth",
                description: "If you're 16 or 17 years old, you can pre-register to vote. You'll automatically be registered to vote on your 18th birthday.",
                action: {
                    if let url = URL(string: "https://www.sos.ca.gov/elections/pre-register-16-vote-18") {
                        UIApplication.shared.open(url)
                    }
                },
                actionText: "Pre-Register"
            )
            
            InfoCard(
                title: "ID Requirements",
                description: "First-time voters who registered online or by mail may need to show ID when voting. Acceptable forms include:\n• CA driver's license\n• Passport\n• Student ID\n• Military ID\n• Utility bill\n• Bank statement",
                action: nil,
                actionText: nil
            )
        }
        .padding()
    }
    
    private var deadlinesSection: some View {
        VStack(spacing: 16) {
            InfoCard(
                title: "Registration Deadlines",
                description: "• Regular registration: 15 days before Election Day\n• Same-day registration: Available through Election Day\n• Mail ballot request: 7 days before Election Day\n• Mail ballot return: Postmarked by Election Day and received within 7 days",
                action: nil,
                actionText: nil
            )
            
            InfoCard(
                title: "2024 Election Calendar",
                description: "Primary Election:\n• Election Day: March 5, 2024\n• Registration Deadline: February 20, 2024\n\nGeneral Election:\n• Election Day: November 5, 2024\n• Registration Deadline: October 21, 2024",
                action: nil,
                actionText: nil
            )
            
            InfoCard(
                title: "Early Voting",
                description: "Early voting locations open 10 days before Election Day. Some counties offer even earlier voting options.",
                action: {
                    if let url = URL(string: "https://caearlyvoting.sos.ca.gov/") {
                        UIApplication.shared.open(url)
                    }
                },
                actionText: "Find Early Voting"
            )
        }
        .padding()
    }
    
    private var rightsSection: some View {
        VStack(spacing: 16) {
            InfoCard(
                title: "Your Voting Rights",
                description: "As a California voter, you have the right to:\n• Cast your ballot privately and independently\n• Receive voting materials in your preferred language\n• Get help casting your ballot\n• Drop off your completed ballot at any polling place\n• Get a new ballot if you make a mistake\n• Vote if you're in line when polls close\n• Vote by mail\n• Report any illegal or fraudulent election activity",
                action: nil,
                actionText: nil
            )
            
            InfoCard(
                title: "Language Access",
                description: "Voting materials are available in:\n• English\n• Spanish\n• Chinese\n• Hindi\n• Japanese\n• Khmer\n• Korean\n• Tagalog\n• Thai\n• Vietnamese",
                action: {
                    if let url = URL(string: "https://www.sos.ca.gov/elections/voting-resources/language-requirements") {
                        UIApplication.shared.open(url)
                    }
                },
                actionText: "Language Resources"
            )
            
            InfoCard(
                title: "Accessible Voting",
                description: "Every polling place offers:\n• Accessible voting machines\n• Curbside voting\n• Physical accessibility\n• Voting assistance\n• Remote accessible vote-by-mail",
                action: {
                    if let url = URL(string: "https://www.sos.ca.gov/elections/voting-resources/voters-disabilities") {
                        UIApplication.shared.open(url)
                    }
                },
                actionText: "Learn More"
            )
        }
        .padding()
    }
    
    private var resourcesSection: some View {
        VStack(spacing: 16) {
            InfoCard(
                title: "Voter Information Guide",
                description: "Access the official guide with information about candidates and ballot measures.",
                action: {
                    if let url = URL(string: "https://voterguide.sos.ca.gov/") {
                        UIApplication.shared.open(url)
                    }
                },
                actionText: "View Guide"
            )
            
            InfoCard(
                title: "Track Your Ballot",
                description: "Sign up for automatic updates about your ballot's status via email, text, or voice call.",
                action: {
                    if let url = URL(string: "https://california.ballottrax.net/voter/") {
                        UIApplication.shared.open(url)
                    }
                },
                actionText: "Track Ballot"
            )
            
            InfoCard(
                title: "County Elections Offices",
                description: "Contact your local elections office for specific questions about voting in your county.",
                action: {
                    if let url = URL(string: "https://www.sos.ca.gov/elections/voting-resources/county-elections-offices") {
                        UIApplication.shared.open(url)
                    }
                },
                actionText: "Find Office"
            )
            
            InfoCard(
                title: "Report Issues",
                description: "Report voting problems or voter intimidation:\n• Voter Hotline: (800) 345-VOTE (8683)\n• Election cybersecurity issues: VoteSure@sos.ca.gov",
                action: nil,
                actionText: nil
            )
            
            InfoCard(
                title: "Additional Resources",
                description: "• League of Women Voters\n• California Secretary of State\n• County Registrar of Voters\n• National Voter Registration Application",
                action: {
                    if let url = URL(string: "https://www.sos.ca.gov/elections/voting-resources/") {
                        UIApplication.shared.open(url)
                    }
                },
                actionText: "More Resources"
            )
        }
        .padding()
    }
}

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    let detail: VoterRegistrationView.DetailInfo
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(detail.content, id: \.self) { text in
                        Text(text)
                            .font(.body)
                    }
                    
                    if !detail.links.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Official Resources")
                                .font(.headline)
                            
                            ForEach(detail.links, id: \.title) { link in
                                Button(action: {
                                    if let url = URL(string: link.url) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Text(link.title)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                    }
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(detail.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

struct InfoCard: View {
    let title: String
    let description: String
    let action: (() -> Void)?
    let actionText: String?
    let showsDetailIndicator: Bool
    
    init(
        title: String,
        description: String,
        action: (() -> Void)? = nil,
        actionText: String? = nil,
        showsDetailIndicator: Bool = false
    ) {
        self.title = title
        self.description = description
        self.action = action
        self.actionText = actionText
        self.showsDetailIndicator = showsDetailIndicator
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                
                if showsDetailIndicator {
                    Spacer()
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                }
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
            
            if let action = action, let actionText = actionText {
                Button(action: action) {
                    Text(actionText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    VoterRegistrationView()
        .environmentObject(MenuState())
} 
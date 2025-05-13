import SwiftUI

struct VoterRegistrationView: View {
    @EnvironmentObject private var menuState: MenuState
    @State private var selectedSection: InfoSection = .registration
    @State private var showingDetailView = false
    @State private var selectedDetail: DetailInfo?
    @State private var showingHelpView = false
    
    enum InfoSection: String, CaseIterable {
        case registration = "Register"
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
                        
                        // Just show the registration section directly since it's the only tab now
                        registrationSection
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        withAnimation {
                            menuState.showingVoterRegistration = false
                            menuState.showingHelp = false
                        }
                    }
                    .foregroundColor(AppColors.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingHelpView = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.blue)
                    }
                }
            }
            .sheet(item: $selectedDetail) { detail in
                DetailView(detail: detail)
            }
            .fullScreenCover(isPresented: $showingHelpView) {
                HelpView()
                    .environmentObject(menuState)
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
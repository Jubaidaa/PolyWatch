import SwiftUI

struct HelpSidebarView: View {
    @EnvironmentObject private var menuState: MenuState
    @State private var selectedSection: InfoSection = .rights
    @State private var selectedDetail: DetailInfo?
    @Environment(\.dismiss) private var dismiss
    
    enum InfoSection: String, CaseIterable {
        case requirements = "Requirements"
        case rights = "Rights"
        case resources = "Resources"
    }
    
    // Define DetailInfo inside HelpSidebarView
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
                            Text("Voter Help & Information")
                                .font(.system(size: 34, weight: .bold))
                            Text("California Voter Resources")
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
                        case .requirements:
                            requirementsSection
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
                    Button("Close") {
                        menuState.returnToMainView()
                    }
                    .foregroundColor(AppColors.blue)
                }
            }
            .sheet(item: $selectedDetail) { detail in
                HelpDetailView(detail: detail)
            }
        }
    }
    
    // Rename DetailView to HelpDetailView
    struct HelpDetailView: View {
        @Environment(\.dismiss) private var dismiss
        let detail: DetailInfo
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(detail.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        ForEach(detail.content, id: \.self) { line in
                            Text(line)
                                .padding(.vertical, line.isEmpty ? 8 : 2)
                        }
                        
                        if !detail.links.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(detail.links, id: \.title) { link in
                                    Button {
                                        if let url = URL(string: link.url) {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        Text(link.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(AppColors.blue)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    // Copy these sections from VoterRegistrationView
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

struct HelpSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        HelpSidebarView()
            .environmentObject(MenuState())
    }
} 
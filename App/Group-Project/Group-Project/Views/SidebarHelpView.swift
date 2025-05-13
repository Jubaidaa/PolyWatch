import SwiftUI

struct SidebarHelpView: View {
    @EnvironmentObject private var menuState: MenuState
    @Environment(\.dismiss) private var dismiss
    
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
                        
                        // Content
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
        }
    }
}

struct SidebarHelpView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarHelpView()
            .environmentObject(MenuState())
    }
} 
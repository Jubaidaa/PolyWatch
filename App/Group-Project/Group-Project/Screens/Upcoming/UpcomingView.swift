import SwiftUI

struct UpcomingView: View {
    @StateObject private var viewModel = ElectionsViewModel()
    @StateObject private var stateManager = StateManager()
    @Environment(\.presentationMode) var presentationMode
    @State private var showVoterRegistration = false
    @State private var selectedView: ViewType = .list
    @EnvironmentObject private var menuState: MenuState
    let onLogoTap: () -> Void
    
    enum ViewType {
        case list
        case calendar
    }
    
    var filteredElections: [Election] {
        guard let selectedState = stateManager.selectedState else {
            return viewModel.elections
        }
        return viewModel.elections.filter { $0.stateName == selectedState }
    }
    
    var body: some View {
        ZStack {
            AppColors.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopBarView(
                    onMenuTap: {
                        withAnimation { menuState.isShowing = true }
                    },
                    onLogoTap: onLogoTap,
                    onSearchTap: {}
                )
                
                // You could insert a picker here to toggle selectedView between .list and .calendar
                
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
                                ForEach(filteredElections.sorted { $0.electionDay < $1.electionDay }) { election in
                                    ElectionCard(election: election, dateFormatter: viewModel.formatDate)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    } else {
                        ElectionCalendarView(onLogoTap: onLogoTap)
                    }
                }
                
                // Voter Action Buttons
                VStack(spacing: Constants.Padding.standard) {
                    Button {
                        if let url = URL(string: Constants.URLs.registerToVote) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                            Text("Register to Vote")
                                .font(.headline)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.primary))
                    .accessibilityHint("Opens voter registration website")
                    
                    Button {
                        if let url = URL(string: Constants.URLs.checkVoterStatus) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
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
        .onAppear {
            viewModel.fetchElections()
        }
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
        UpcomingView(onLogoTap: {})
            .environmentObject(MenuState())
    }
}


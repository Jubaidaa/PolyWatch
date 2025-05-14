import SwiftUI

struct UpcomingView: View {
    @StateObject private var viewModel = ElectionsViewModel()
    @StateObject private var stateManager = StateManager()
    @Environment(\.presentationMode) var presentationMode
    @State private var showVoterRegistration = false
    @State private var selectedView: ViewType = .calendar
    @EnvironmentObject private var menuState: MenuState
    let onLogoTap: () -> Void
    
    init(onLogoTap: @escaping () -> Void) {
        self.onLogoTap = onLogoTap
        // Hide back button text
        UINavigationBar.appearance().backIndicatorImage = UIImage()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage()
        
        // Remove the text
        let barAppearance = UIBarButtonItem.appearance()
        barAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -200, vertical: 0), for: .default)
    }
    
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
        NavigationView {
        ZStack {
            AppColors.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopBarView(
                    onMenuTap: {
                        withAnimation { menuState.isShowing = true }
                    },
                    onLogoTap: {
                        withAnimation {
                            menuState.returnToMainView()
                        }
                    },
                    onSearchTap: {},
                    showBackButton: true,
                    onBackTap: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading elections...")
                    Spacer()
                    
                } else if let error = viewModel.error {
                    Spacer()
                    VStack(spacing: Constants.Padding.standard) {
                        Text("😕")
                            .font(.system(size: 64))
                        Text("We can't connect to the election data service right now.")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Text("Please check your internet connection and try again.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)
                        Button("Try Again") {
                            viewModel.fetchElections()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        // Show calendar view as fallback
                        Button("View Election Calendar") {
                            selectedView = .calendar
                            // Force refresh
                            viewModel.error = nil
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .padding(.top, 8)
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
                            NavigationView {
                        ElectionCalendarView(
                            onLogoTap: {
                                withAnimation {
                                    menuState.returnToMainView()
                                }
                            },
                                    showTopBar: true,
                                    isEmbedded: true
                        )
                                .environmentObject(menuState)
                                .navigationBarHidden(true)
                                .navigationBarBackButtonHidden(true)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarLeading) {
                                        EmptyView()
                                    }
                                }
                            }
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                
                // Voter Action Buttons
                VStack(spacing: Constants.Padding.standard) {
                    Button {
                        showVoterRegistration = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                            Text("Register to Vote")
                                .font(.headline)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.primary))
                    .accessibilityHint("Shows California voter registration info")
                    .sheet(isPresented: $showVoterRegistration) {
                        VoterRegistrationView()
                            .environmentObject(menuState)
                    }
                    
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
            .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.fetchElections()
        }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
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


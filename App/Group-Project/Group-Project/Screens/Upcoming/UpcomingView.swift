import SwiftUI

struct UpcomingView: View {
    @StateObject private var viewModel = ElectionsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
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
                    ScrollView {
                        LazyVStack(spacing: Constants.Padding.standard) {
                            ForEach(viewModel.elections) { election in
                                ElectionCard(election: election, dateFormatter: viewModel.formatDate)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
                
                // Voter Action Buttons
                VStack(spacing: Constants.Padding.standard) {
                    Button(action: {
                        if let url = URL(string: Constants.URLs.registerToVote) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                            Text("Register to Vote")
                                .font(.headline)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.Button.primary))
                    .accessibilityHint("Opens voter registration website")
                    
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
        UpcomingView()
    }
} 
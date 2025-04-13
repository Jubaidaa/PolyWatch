import SwiftUI

struct UpcomingView: View {
    @StateObject private var viewModel = ElectionsFeedViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background
            AppColors.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                TopBarView(
                    onMenuTap: {},
                    onLogoTap: { presentationMode.wrappedValue.dismiss() },
                    onSearchTap: {}
                )
                
                Spacer()
                
                // Center Image
                Image("vote")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .padding(.vertical, Constants.Padding.standard / 2)
                    .accessibilityLabel("Voting Information")
                
                Spacer()
                
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
    }
}

struct UpcomingView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingView()
    }
} 
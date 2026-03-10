import SwiftUI

class ElectionsFeedViewModel: ObservableObject {
    @Published var isLoading = false
    
    let electionFeeds = [
        ("https://www.vote.org/feed/", "Vote.org"),
        ("https://www.ballotpedia.org/feed", "Ballotpedia")
    ]
    
    func fetchElectionData() {
        isLoading = true
        // TODO: Implement actual election data fetching
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
        }
    }
} 
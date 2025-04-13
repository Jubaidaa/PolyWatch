import Foundation
import UIKit

enum Constants {
    enum URLs {
        static let registerToVote = "https://www.vote.org/register-to-vote/"
        static let checkVoterStatus = "https://www.vote.org/am-i-registered-to-vote/"
        static let voteOrgFeed = "https://www.vote.org/feed/"
        static let ballotpediaFeed = "https://www.ballotpedia.org/feed"
    }
    
    enum Images {
        static let sideIcon = "sideicon"
        static let voteImage = "vote_image"
    }
    
    enum Dimensions {
        static let topBarHeight: CGFloat = 100
        static let buttonHeight: CGFloat = 50
        static let logoSize: CGFloat = 250
        static let iconSize: CGFloat = 28
        static let cornerRadius: CGFloat = 8
        
        // Logo specific dimensions
        static let topBarLogoWidth: CGFloat = logoSize * 0.4
        static let topBarLogoHeight: CGFloat = topBarHeight - 20
        static let mainLogoWidth: CGFloat = UIScreen.main.bounds.width * 0.8  // Larger size for main content areas
    }
    
    enum Padding {
        static let standard: CGFloat = 16
        static let large: CGFloat = 32
        static let vertical: CGFloat = 12
        static let bottom: CGFloat = 40
    }
} 
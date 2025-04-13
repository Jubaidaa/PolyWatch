import SwiftUI

enum AppColors {
    static let red = Color(red: 178/255, green: 34/255, blue: 52/255)    // #B22234
    static let blue = Color(red: 60/255, green: 59/255, blue: 110/255)   // #3C3B6E
    static let white = Color.white
    
    enum Button {
        static let primary = red
        static let secondary = blue
        static let text = white
    }
    
    enum TopBar {
        static let background = red
        static let icons = white
    }
} 
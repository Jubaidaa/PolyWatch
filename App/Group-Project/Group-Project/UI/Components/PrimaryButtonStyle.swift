import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let isFullWidth: Bool
    
    init(backgroundColor: Color = AppColors.Button.primary, isFullWidth: Bool = true) {
        self.backgroundColor = backgroundColor
        self.isFullWidth = isFullWidth
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isFullWidth { Spacer() }
            configuration.label
            if isFullWidth { Spacer() }
        }
        .foregroundColor(AppColors.Button.text)
        .frame(minHeight: Constants.Dimensions.buttonHeight)
        .background(backgroundColor)
        .cornerRadius(Constants.Dimensions.cornerRadius)
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .opacity(configuration.isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
} 
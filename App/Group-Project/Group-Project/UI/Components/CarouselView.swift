import SwiftUI

struct CarouselItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
}

struct CarouselView: View {
    let items: [CarouselItem]
    @Binding var currentIndex: Int
    
    private let timer = Timer.publish(every: 4.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.Dimensions.cornerRadius * 2)
                .fill(AppColors.blue)
            
            if !items.isEmpty {
                TabView(selection: $currentIndex) {
                    ForEach(items.indices, id: \.self) { index in
                        VStack(spacing: Constants.Padding.standard) {
                            // Fallback to system image if asset not found
                            Group {
                                if UIImage(named: items[index].imageName) != nil {
                                    Image(items[index].imageName)
                                        .resizable()
                                        .scaledToFit()
                                } else {
                                    Image(systemName: "newspaper")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(height: 180)
                            .cornerRadius(Constants.Dimensions.cornerRadius)
                            .accessibilityLabel(items[index].title)
                            
                            Text(items[index].title)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .foregroundColor(AppColors.white)
                                .padding(.horizontal, Constants.Padding.standard)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .onReceive(timer) { _ in
                    withAnimation(.easeInOut) {
                        currentIndex = (currentIndex + 1) % items.count
                    }
                }
                .padding(24)
            } else {
                Text("No items available")
                    .foregroundColor(AppColors.white)
            }
        }
        .frame(height: 400)
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView(
            items: [
                CarouselItem(title: "Test 1", imageName: "newspaper"),
                CarouselItem(title: "Test 2", imageName: "newspaper")
            ],
            currentIndex: .constant(0)
        )
        .padding()
    }
} 
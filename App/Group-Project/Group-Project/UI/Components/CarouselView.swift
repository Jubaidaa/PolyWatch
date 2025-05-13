import SwiftUI

struct CarouselItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let articleImage: String?
}

struct CarouselView: View {
    let items: [CarouselItem]
    @Binding var currentIndex: Int
    
    private let timer = Timer.publish(every: 4.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: Constants.Dimensions.cornerRadius * 2)
                    .fill(AppColors.blue)
                
                if !items.isEmpty {
                    TabView(selection: $currentIndex) {
                        ForEach(items.indices, id: \ .self) { index in
                            ZStack(alignment: .bottom) {
                                // Use article image if available, otherwise fallback to system image
                                Group {
                                    if let articleImage = items[index].articleImage {
                                        AsyncImage(url: URL(string: articleImage)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                                    .clipped()
                                            case .failure:
                                                Image(systemName: "newspaper")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.white)
                                            @unknown default:
                                                Image(systemName: "newspaper")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    } else if UIImage(named: items[index].imageName) != nil {
                                        Image(items[index].imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                            .clipped()
                                    } else {
                                        Image(systemName: "newspaper")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.white)
                                    }
                                }
                                .accessibilityLabel(items[index].title)
                                
                                // Overlay title and dots
                                VStack(spacing: 16) {
                                    Spacer()
                                    Text(items[index].title)
                                        .font(.title3)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(AppColors.white)
                                        .padding(.horizontal, Constants.Padding.standard)
                                        .shadow(radius: 8)
                                    // Page dots
                                    HStack(spacing: 8) {
                                        ForEach(items.indices, id: \ .self) { dotIndex in
                                            Circle()
                                                .fill(dotIndex == currentIndex ? Color.white : Color.white.opacity(0.4))
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    .padding(.bottom, 16)
                                }
                                .frame(width: geometry.size.width)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onReceive(timer) { _ in
                        withAnimation(.easeInOut) {
                            currentIndex = (currentIndex + 1) % items.count
                        }
                    }
                } else {
                    Text("No items available")
                        .foregroundColor(AppColors.white)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Constants.Dimensions.cornerRadius * 2))
        }
        .aspectRatio(2.5, contentMode: .fit)
        .frame(maxHeight: 220)
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView(
            items: [
                CarouselItem(title: "Test 1", imageName: "newspaper", articleImage: nil),
                CarouselItem(title: "Test 2", imageName: "newspaper", articleImage: nil)
            ],
            currentIndex: .constant(0)
        )
        .padding()
    }
} 
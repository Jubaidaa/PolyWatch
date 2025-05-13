import SwiftUI

struct CarouselItem: Identifiable {
    let id = UUID()
    let title: String
    let imageUrl: String?
}

struct CarouselView: View {
    let items: [CarouselItem]
    @Binding var currentIndex: Int

    private let timer = Timer.publish(every: 4.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray5))

            if !items.isEmpty {
                TabView(selection: $currentIndex) {
                    ForEach(items.indices, id: \ .self) { index in
                        ZStack(alignment: .bottom) {
                            // Image
                            if let urlString = items[index].imageUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        Color.gray.opacity(0.2)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
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
                            } else {
                                Image(systemName: "newspaper")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                            }
                            // Overlay
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            VStack(spacing: 10) {
                                Spacer()
                                Text(items[index].title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 12)
                                    .shadow(radius: 8)
                                HStack(spacing: 8) {
                                    ForEach(items.indices, id: \ .self) { dotIndex in
                                        Circle()
                                            .fill(dotIndex == currentIndex ? Color.white : Color.white.opacity(0.4))
                                            .frame(width: 8, height: 8)
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(width: 300, height: 180)
                        .clipped()
                        .cornerRadius(20)
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
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 300, height: 180)
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
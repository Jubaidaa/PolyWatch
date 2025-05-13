import SwiftUI

struct CarouselItem: Identifiable {
    let id = UUID()
    let title: String
    let imageUrl: String?
}

struct CarouselView: View {
    let items: [CarouselItem]
    @Binding var currentIndex: Int // Not used in this version, but kept for compatibility

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(items) { item in
                    VStack(spacing: 12) {
                        ZStack {
                            if let urlString = item.imageUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        Rectangle().fill(Color.gray.opacity(0.2))
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    case .failure:
                                        Rectangle().fill(Color.gray.opacity(0.2))
                                    @unknown default:
                                        Rectangle().fill(Color.gray.opacity(0.2))
                                    }
                                }
                                .frame(width: 140, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                Image(systemName: "newspaper")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140, height: 90)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        Text(item.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .frame(width: 140)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 140)
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView(
            items: [
                CarouselItem(title: "Test 1", imageUrl: nil),
                CarouselItem(title: "Test 2", imageUrl: nil)
            ],
            currentIndex: .constant(0)
        )
        .padding()
    }
} 
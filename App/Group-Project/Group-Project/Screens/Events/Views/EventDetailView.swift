import SwiftUI
import SafariServices

struct EventDetailView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    @State private var showingRegistration = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Event Image
                if let imageURL = event.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(height: 240)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Status
                    VStack(alignment: .leading, spacing: 8) {
                        if event.status != .upcoming {
                            Text(event.status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(statusColor.opacity(0.2))
                                .foregroundColor(statusColor)
                                .clipShape(Capsule())
                        }
                        
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    // Date and Time
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Date and Time")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text(event.formattedDate)
                                .foregroundColor(.gray)
                        }
                        
                        if let endDate = event.endDate {
                            Text("to")
                                .foregroundColor(.gray)
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                                Text(formatDate(endDate))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // Location
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location")
                            .font(.headline)
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.gray)
                            Text(event.location)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Price
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Price")
                            .font(.headline)
                        if event.isFree {
                            Text("Free")
                                .foregroundColor(.green)
                                .font(.body.bold())
                        } else if let price = event.price {
                            Text(price.formatted)
                                .font(.body.bold())
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 4) {
                        Text("About this event")
                            .font(.headline)
                        Text(event.description)
                            .foregroundColor(.gray)
                    }
                    
                    // Organizer
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Organizer")
                            .font(.headline)
                        Text(event.organizer)
                            .foregroundColor(.gray)
                    }
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(event.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // Eventbrite Attribution
                    HStack {
                        Spacer()
                        Text("Powered by")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Image("eventbrite-logo") // You'll need to add this image to your assets
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if event.registrationRequired {
                    Button("Register") {
                        showingRegistration = true
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingRegistration) {
            if let url = event.registrationURL, let registrationURL = URL(string: url) {
                SafariView(url: registrationURL)
            }
        }
    }
    
    private var statusColor: Color {
        switch event.status {
        case .almostFull:
            return .orange
        case .soldOut:
            return .red
        case .cancelled:
            return .gray
        case .upcoming:
            return .blue
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Helper view for tag layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var height: CGFloat = 0
        var currentRow: CGFloat = 0
        var currentX: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for size in sizes {
            if currentX + size.width > (proposal.width ?? .infinity) {
                height += currentRow + spacing
                currentRow = size.height
                currentX = size.width + spacing
            } else {
                currentRow = max(currentRow, size.height)
                currentX += size.width + spacing
            }
            maxWidth = max(maxWidth, currentX)
        }
        height += currentRow
        
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var currentRow: CGFloat = 0
        var currentX = bounds.minX
        var currentY = bounds.minY
        
        for (index, size) in sizes.enumerated() {
            if currentX + size.width > bounds.maxX {
                currentY += currentRow + spacing
                currentRow = size.height
                currentX = bounds.minX
            } else {
                currentRow = max(currentRow, size.height)
            }
            
            subviews[index].place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(size)
            )
            currentX += size.width + spacing
        }
    }
}

// Safari View for registration
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    NavigationView {
        EventDetailView(event: Event(
            title: "Sample Event",
            date: Date(),
            endDate: Date().addingTimeInterval(3600 * 2),
            location: "Sample Location",
            description: "This is a sample event description that shows how the detail view looks.",
            imageURL: nil,
            price: Event.Price(amount: 25.0, currency: "USD"),
            registrationRequired: true,
            registrationURL: "https://example.com",
            organizer: "Sample Organizer",
            tags: ["Sample", "Preview", "Test"],
            status: .upcoming
        ))
    }
} 
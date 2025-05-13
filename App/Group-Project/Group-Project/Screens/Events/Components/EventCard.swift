import SwiftUI

struct EventCard: View {
    let event: Event
    
    var body: some View {
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
                .frame(height: 160)
                .clipped()
            }
            
            VStack(alignment: .leading, spacing: 12) {
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
                        .font(.headline)
                        .lineLimit(2)
                }
                
                // Date and Location
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text(event.shortFormattedDate)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.gray)
                    Text(event.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
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
}

#Preview {
    // Create a sample event using the proper initializer
    let sampleEvent = Event(
        title: "Sample Event",
        date: Date(),
        endDate: nil,
        location: "123 Main St",
        description: "A sample event description",
        imageURL: nil, 
        price: nil,
        registrationRequired: true,
        registrationURL: nil,
        organizer: "Sample Organizer",
        tags: ["Sample", "Event"],
        status: Event.Status.upcoming,
        state: "CA"
    )
    
    EventCard(event: sampleEvent)
} 
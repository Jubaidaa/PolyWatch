import SwiftUI
import Foundation

struct EventRow: View {
    let event: Event
    
    var body: some View {
        NavigationLink(destination: EventDetailView(event: event)) {
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
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text(event.shortFormattedDate)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.gray)
                            Text(event.location)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                    .font(.subheadline)
                    
                    // Price and Registration
                    HStack {
                        if event.isFree {
                            Text("Free")
                                .foregroundColor(.green)
                                .font(.subheadline.bold())
                        } else if let price = event.price {
                            Text(price.formatted)
                                .font(.subheadline.bold())
                        }
                        
                        Spacer()
                        
                        if event.registrationRequired {
                            Text("Registration required")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
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
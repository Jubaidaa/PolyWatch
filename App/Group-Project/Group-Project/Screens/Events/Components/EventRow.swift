import SwiftUI
import Foundation

struct EventRow: View {
    let event: Event
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Padding.standard / 2) {
            Text(event.title)
                .font(.headline)
            
            HStack {
                Image(systemName: "calendar")
                Text(dateFormatter.string(from: event.date))
                    .font(.subheadline)
            }
            .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "location")
                Text(event.location)
                    .font(.subheadline)
            }
            .foregroundColor(.gray)
            
            Text(event.description)
                .font(.body)
                .padding(.top, 4)
        }
        .padding(.vertical, Constants.Padding.standard)
    }
} 
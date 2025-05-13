// EventDetailView.swift
// Displays detailed information about a single Event

import SwiftUI
import SafariServices

struct EventDetailView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var menuState: MenuState
    @State private var showingRegistration = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                if let imageURL = event.imageURL,
                   let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 240)
                    .clipped()
                }

                VStack(alignment: .leading, spacing: 20) {
                    // Title & Status
                    VStack(alignment: .leading, spacing: 8) {
                        if event.status != .upcoming {
                            Text(event.status.rawValue.capitalized)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(statusColor.opacity(0.2))
                                .foregroundColor(statusColor)
                                .clipShape(Capsule())
                        }
                        Text(event.title)
                            .font(.title)
                            .bold()
                    }

                    // Date & Time
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Date & Time")
                            .font(.headline)
                        HStack {
                            Image(systemName: "calendar")
                            Text(event.formattedDate)
                                .foregroundColor(.gray)
                        }
                        if let endDate = event.endDate {
                            HStack {
                                Text("to")
                                Image(systemName: "calendar")
                                Text(formatDate(endDate))
                            }
                            .foregroundColor(.gray)
                        }
                    }

                    // Location
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location")
                            .font(.headline)
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                            Text(event.location)
                        }
                        .foregroundColor(.gray)
                    }

                    // Price
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Price")
                            .font(.headline)
                        if event.isFree {
                            Text("Free")
                                .foregroundColor(.green)
                                .bold()
                        } else if let price = event.price {
                            Text(price.formatted)
                                .bold()
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
                        Image("eventbrite-logo")
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
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Home") {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            menuState.closeAllOverlays()
                        }
                    }
                }
            }
            
            if event.registrationRequired {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Register") {
                        showingRegistration = true
                    }
                    .bold()
                }
            }
        }
        .sheet(isPresented: $showingRegistration) {
            if let urlString = event.registrationURL,
               let url = URL(string: urlString) {
                SafariView(url: url)
            }
        }
    }

    private var statusColor: Color {
        switch event.status {
        case .almostFull: return .orange
        case .soldOut:     return .red
        case .cancelled:   return .gray
        case .upcoming:    return .blue
        }
    }

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }
}

// Helper for tag wrapping
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var height: CGFloat = 0
        var currentRow: CGFloat = 0
        var currentX: CGFloat = 0
        var maxWidth: CGFloat = 0

        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

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
        var currentRow: CGFloat = 0
        var currentX = bounds.minX
        var currentY = bounds.minY

        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

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

// Safari integration
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventDetailView(event: Event(
                title: "Sample Event",
                date: Date(),
                endDate: nil,
                location: "123 Main St",
                description: "A sample event description",
                imageURL: nil,
                price: Event.Price.free,
                registrationRequired: true,
                registrationURL: nil,
                organizer: "Sample Organizer",
                tags: ["Sample", "Event"],
                status: .upcoming,
                state: nil
            ))
        }
    }
}


# PolyWatch

An iOS app for civic engagement — stay informed about elections, political events, and local news all in one place.

Built as a final project for ISYS 556.

---

## Features

- **Breaking News & Local News** — Aggregates articles from 9+ RSS sources (Al Jazeera, France24, Mission Local, SF Bay View, The Progressive, etc.)
- **Upcoming Elections** — Federal, state, and local election data powered by the Google Civic Info API
- **Political Events** — Rallies, town halls, canvassing events, and voter registration drives via MobilizeAmerica
- **Election Calendar** — Visual calendar view of upcoming elections
- **Voter Registration** — Direct links to state voter registration services
- **Push Notifications** — Alerts for important political events

## Screenshots

> Coming soon

## Tech Stack

- **SwiftUI** — UI framework
- **MVVM** architecture with `ObservableObject` / `async-await`
- **FeedKit** — RSS/Atom/JSON feed parsing
- **Google Civic Info API** — Election data
- **MobilizeAmerica API** — Political events

## Getting Started

1. Clone the repo
2. Open `App/Group-Project/PolyWatch.xcodeproj` in Xcode
3. Add your Google Civic Info API key in `ViewModels/ElectionsViewModel.swift`:

```swift
self.service = ElectionService(apiKey: "YOUR_API_KEY_HERE")
```

4. Build and run on a simulator or device (iOS 16+)

## Project Structure

```
App/Group-Project/Group-Project/
├── Screens/          # Main app screens (Home, Events, Upcoming)
├── Views/            # Modal and detail views
├── ViewModels/       # Data fetching and business logic
├── Services/         # RSS, Election, and Notification services
├── Models/           # Data models
├── UI/Components/    # Reusable UI components
└── State/            # Global app state managers
```

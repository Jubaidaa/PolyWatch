import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Get Involved in Politics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                NavigationLink(destination: VoteView()) {
                    ButtonView(title: "VOTE", systemImage: "hand.thumbsup")
                }
                
                NavigationLink(destination: NewsFeedView()) {
                    ButtonView(title: "Local News", systemImage: "newspaper")
                }
                
                NavigationLink(destination: UpcomingElectionsView()) {
                    ButtonView(title: "Upcoming Elections", systemImage: "calendar")
                }
                
                NavigationLink(destination: EventsView()) {
                    ButtonView(title: "Events", systemImage: "megaphone")
                }
                
                NavigationLink(destination: RegistrationView()) {
                    ButtonView(title: "Register to Vote", systemImage: "person.badge.plus")
                }
                
                Spacer()
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.purple.opacity(0.5)]),
                             startPoint: .top,
                             endPoint: .bottom)
                .ignoresSafeArea()
            )
        }
    }
}

struct ButtonView: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.headline)
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .foregroundColor(.purple)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal, 40)
    }
}

struct VoteView: View {
    var body: some View {
        VStack {
            Text("Thank you for participating!")
                .font(.title)
                .padding()
        }
        .navigationTitle("Vote")
    }
}

struct UpcomingElectionsView: View {
    var body: some View {
        VStack {
            Text("Upcoming Elections")
                .font(.title)
                .padding()
        }
        .navigationTitle("Upcoming Elections")
    }
}

struct EventsView: View {
    var body: some View {
        VStack {
            Text("Upcoming Events")
                .font(.title)
                .padding()
        }
        .navigationTitle("Events")
    }
}

struct RegistrationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("check_registration", comment: "Check your registration status"))
                .font(.headline)
                .multilineTextAlignment(.center)

            Link(NSLocalizedString("check_status", comment: "Check Status"), destination: URL(string: "https://voterstatus.sos.ca.gov/")!)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)

            Text(NSLocalizedString("not_registered", comment: "If you're not registered, you can register below:"))

            Link(NSLocalizedString("register_to_vote", comment: "Register to Vote"), destination: URL(string: "https://registertovote.ca.gov/")!)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .navigationTitle(NSLocalizedString("registration", comment: "Registration"))
    }
}


struct PoliticsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

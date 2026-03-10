import SwiftUI

struct UserProfileView: View {
    @AppStorage("profileName") private var name: String = "John Doe"
    @AppStorage("profilePhone") private var phone: String = "+1 555-123-4567"
    @AppStorage("profileEmail") private var email: String = "johndoe@email.com"
    @AppStorage("profileState") private var selectedState: String = "California"
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var menuState: MenuState
    @EnvironmentObject private var notificationService: NotificationService
    
    let states = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California",
        "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
        "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
        "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
        "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri",
        "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey",
        "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
        "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
        "South Dakota", "Tennessee", "Texas", "Utah", "Vermont",
        "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
    ]
    
    @State private var showStatePicker = false
    @State private var showNotificationSettings = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Info")) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(name)
                                .font(.headline)
                            Text(phone)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("State")) {
                    Button(action: { showStatePicker = true }) {
                        HStack {
                            Text("State:")
                            Spacer()
                            Text(selectedState)
                                .foregroundColor(.blue)
                                .bold()
                        }
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Button(action: { showNotificationSettings = true }) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.red)
                            Text("Notification Settings")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                    }
                    
                    Button(action: {
                        notificationService.scheduleImmediateNotification()
                    }) {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.red)
                            Text("Send Test Notification")
                        }
                    }
                }
                
                Section {
                    Button(action: logout) {
                        Text("Log Out")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showStatePicker) {
                StatePickerView(selectedState: $selectedState, states: states)
            }
            .sheet(isPresented: $showNotificationSettings) {
                NotificationSettingsView()
            }
        }
    }
    
    func logout() {
        name = "John Doe"
        phone = "+1 555-123-4567"
        email = "johndoe@email.com"
        selectedState = "California"
        menuState.closeAllOverlays()
        presentationMode.wrappedValue.dismiss()
    }
}

struct StatePickerView: View {
    @Binding var selectedState: String
    let states: [String]
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            List(states, id: \.self) { state in
                HStack {
                    Text(state)
                    Spacer()
                    if state == selectedState {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedState = state
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Select State")
        }
    }
}

#Preview {
    UserProfileView()
        .environmentObject(MenuState())
        .environmentObject(NotificationService())
} 
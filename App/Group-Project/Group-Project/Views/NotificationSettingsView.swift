import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject private var notificationService: NotificationService
    @Environment(\.presentationMode) var presentationMode
    @State private var isNotificationsEnabled = true
    @State private var selectedFrequency = 1 // Default to 5 minutes (index 1)
    
    let frequencies = ["1 minute", "5 minutes", "15 minutes", "30 minutes", "1 hour"]
    let frequencyValues = [60.0, 300.0, 900.0, 1800.0, 3600.0] // in seconds
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notification Settings")) {
                    Toggle("Enable Notifications", isOn: $isNotificationsEnabled)
                        .onChange(of: isNotificationsEnabled) { _, newValue in
                            if newValue {
                                notificationService.requestAuthorization()
                            } else {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            }
                        }
                    
                    if isNotificationsEnabled {
                        Picker("Frequency", selection: $selectedFrequency) {
                            ForEach(0..<frequencies.count, id: \.self) { index in
                                Text(frequencies[index]).tag(index)
                            }
                        }
                        .onChange(of: selectedFrequency) { _, newValue in
                            notificationService.updateNotificationFrequency(frequencyValues[newValue])
                        }
                    }
                }
                
                Section(header: Text("Notification Types")) {
                    NavigationLink(destination: NotificationCategoriesView()) {
                        Text("Customize Notification Categories")
                    }
                }
                
                Section(header: Text("About Notifications")) {
                    Text("PolyWatch sends you timely updates about political events, election information, and civic engagement opportunities.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Notification Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct NotificationCategoriesView: View {
    @State private var categories = [
        NotificationCategory(name: "Breaking News", isEnabled: true),
        NotificationCategory(name: "Election Updates", isEnabled: true),
        NotificationCategory(name: "Voter Information", isEnabled: true),
        NotificationCategory(name: "Policy Changes", isEnabled: true),
        NotificationCategory(name: "Community Events", isEnabled: true),
        NotificationCategory(name: "Fact Checks", isEnabled: true)
    ]
    
    var body: some View {
        List {
            ForEach(0..<categories.count, id: \.self) { index in
                Toggle(categories[index].name, isOn: $categories[index].isEnabled)
            }
        }
        .navigationTitle("Notification Categories")
    }
}

struct NotificationCategory {
    let name: String
    var isEnabled: Bool
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
            .environmentObject(NotificationService())
    }
} 
import Foundation
import UserNotifications

class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var isAuthorized = false
    private let notificationCenter = UNUserNotificationCenter.current()
    private var notificationFrequency: TimeInterval = 300.0 // Default to 5 minutes
    
    // Array of interesting political notifications
    private let notificationMessages = [
        "Breaking: New poll shows tight race in upcoming election!",
        "Reminder: Town hall meeting tonight at 7PM",
        "Fact check: Learn the truth about recent policy claims",
        "Your voice matters! Register to vote before the deadline",
        "New candidate announcement in your district",
        "Election day is approaching - check your polling location",
        "Breaking: Supreme Court decision on key legislation",
        "Local impact: How new policies affect your community",
        "Upcoming debate tonight - tune in at 8PM",
        "Voter registration drive this weekend at City Hall",
        "Campaign finance update: See who's funding the candidates",
        "Policy alert: New environmental regulations proposed",
        "Community update: School board meeting results",
        "Voter guide: Compare candidate positions on key issues",
        "Election security update: New measures in place",
        "Reminder: Early voting begins next week",
        "Breaking: Major endorsement announced for local candidate",
        "Legislative update: New bill passed affecting healthcare",
        "Civic engagement opportunity: Volunteer for local campaigns",
        "Policy explainer: Understanding the new tax proposal"
    ]
    
    // Array of call-to-action subtitles
    private let callToActions = [
        "Tap to learn more",
        "Stay informed",
        "Get the facts",
        "Take action now",
        "Stay engaged",
        "Be a voter",
        "Make your voice heard",
        "Stay up to date",
        "Be part of democracy",
        "Knowledge is power"
    ]
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if granted {
                    self?.scheduleNotifications()
                }
            }
        }
    }
    
    func updateNotificationFrequency(_ frequency: TimeInterval) {
        self.notificationFrequency = frequency
        if isAuthorized {
            scheduleNotifications()
        }
    }
    
    func scheduleNotifications() {
        // Cancel any existing notifications
        notificationCenter.removeAllPendingNotificationRequests()
        
        // Schedule notifications for the next 24 hours based on frequency
        let numberOfNotifications = Int(24 * 60 * 60 / notificationFrequency)
        let maxNotifications = min(numberOfNotifications, 64) // iOS has a limit of 64 scheduled notifications
        
        for i in 0..<maxNotifications {
            let notification = createRandomNotification(index: i)
            notificationCenter.add(notification) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func createRandomNotification(index: Int) -> UNNotificationRequest {
        // Create content
        let content = UNMutableNotificationContent()
        content.title = notificationMessages.randomElement() ?? "PolyWatch Update"
        content.subtitle = callToActions.randomElement() ?? "Stay informed"
        content.sound = UNNotificationSound.default
        
        // Create trigger based on current frequency setting
        let triggerTime = notificationFrequency * Double(index + 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)
        
        // Create request
        let identifier = "PolyWatch-\(UUID().uuidString)"
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
    
    // Schedule a specific notification immediately (for testing)
    func scheduleImmediateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "PolyWatch Notifications Activated!"
        content.subtitle = "You'll receive updates every \(Int(notificationFrequency/60)) minutes"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "PolyWatch-Immediate", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling immediate notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even when the app is in foreground
        completionHandler([.banner, .sound])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification tap here
        // You could navigate to a specific view based on the notification
        completionHandler()
    }
} 
import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func sendTrackerAlert(device: TrackerDevice) {
        let content = UNMutableNotificationContent()
        content.title = "不審なトラッカーを検出"
        content.body = "\(device.type.description)が\(device.durationText)間あなたの近くにあります。安全を確認してください。"
        content.sound = .defaultCritical
        content.categoryIdentifier = "TRACKER_ALERT"

        let request = UNNotificationRequest(
            identifier: device.peripheralIdentifier.uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}

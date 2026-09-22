import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    func requestPermission() async throws { _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) }
    func scheduleWater(at hour: Int = 12, minute: Int = 0) async throws { var date = DateComponents(); date.hour = hour; date.minute = minute; let content = UNMutableNotificationContent(); content.title = "FITLY"; content.body = "Время выпить воды"; content.sound = .default; let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true); try await UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "fitly.water", content: content, trigger: trigger)) }
    func cancelAll() { UNUserNotificationCenter.current().removeAllPendingNotificationRequests() }
}

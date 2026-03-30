import Foundation
import UserNotifications

@MainActor
final class NotificationManager: Observable {
    static let shared = NotificationManager()

    private(set) var isAuthorized = false

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
        } catch {
            isAuthorized = false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Daily Plan Reminder

    func scheduleDailyReminder(hour: Int, minute: Int) {
        let id = "daily-plan-reminder"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = "今日计划已就绪"
        content.body = "查看今天的训练内容和饮食清单"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Pre-workout Meal Reminder

    /// Schedule a reminder 1 hour before estimated training time
    func schedulePreWorkoutReminder(trainingHour: Int) {
        let id = "preworkout-meal-reminder"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])

        let reminderHour = max(trainingHour - 1, 0)

        let content = UNMutableNotificationContent()
        content.title = "训练前加餐提醒"
        content.body = "距离训练还有约 1 小时，别忘了训练前加餐"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel All

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

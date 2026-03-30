import Foundation
import SwiftData
import CycleEngine

@Observable
@MainActor
final class WeekViewModel {
    var weekPlans: [DailyPlan] = []
    var trainingDayPlans: [TrainingDayPlan] = []
    var weekStartDate: Date = Date()

    private var repo: DataRepository?

    func load(repo: DataRepository) {
        self.repo = repo
        refresh()
    }

    func refresh() {
        guard let repo else { return }
        weekStartDate = currentWeekStart()
        weekPlans = repo.fetchWeekPlans(from: weekStartDate)

        if weekPlans.isEmpty {
            weekPlans = repo.generateWeekPlan(startDate: weekStartDate)
        }

        let seedData = SeedDataLoader.shared
        seedData.loadIfNeeded()
        trainingDayPlans = seedData.defaultTrainingTemplate?.dayPlans ?? []
    }

    func trainingInfo(for dayIndex: Int) -> TrainingDayPlan? {
        trainingDayPlans.first { $0.dayIndex == dayIndex }
    }

    private func currentWeekStart() -> Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        return cal.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
    }
}

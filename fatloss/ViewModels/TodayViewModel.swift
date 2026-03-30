import Foundation
import SwiftData
import CycleEngine

@Observable
@MainActor
final class TodayViewModel {
    var todayPlan: DailyPlan?
    var trainingDayPlan: TrainingDayPlan?

    /// Resolved meal items with food names and cooked weights
    var resolvedMeals: [ResolvedMeal] = []

    struct ResolvedMeal: Identifiable {
        let id = UUID()
        let label: String
        let mealType: String
        var items: [ResolvedMealItem]
    }

    struct ResolvedMealItem: Identifiable {
        let id = UUID()
        let foodName: String
        let weightRaw: Double
        let weightCooked: Double
        let protein: Double
        let carb: Double
        let fat: Double
        let calories: Double
    }

    private var repo: DataRepository?

    func load(repo: DataRepository) {
        self.repo = repo
        refresh()
    }

    func refresh() {
        guard let repo else { return }
        todayPlan = repo.fetchTodayPlan()

        if todayPlan == nil {
            let plans = repo.generateWeekPlan(startDate: currentWeekStart())
            todayPlan = plans.first { Calendar.current.isDateInToday($0.date) }
        }

        resolveTrainingInfo()
        resolveMeals()
    }

    func markTrainingDone(feedback: DailyPlan.TrainingFeedback?) {
        guard let repo, let plan = todayPlan else { return }
        repo.markTrainingCompleted(plan, feedback: feedback)
        repo.save()
    }

    func markMealDone() {
        guard let repo, let plan = todayPlan else { return }
        repo.markMealCompleted(plan)
        repo.save()
    }

    private func resolveTrainingInfo() {
        guard let plan = todayPlan else {
            trainingDayPlan = nil
            return
        }
        let seedData = SeedDataLoader.shared
        seedData.loadIfNeeded()
        guard let template = seedData.defaultTrainingTemplate else { return }
        trainingDayPlan = template.dayPlans.first { $0.dayIndex == plan.dayIndex }
    }

    private func resolveMeals() {
        guard let plan = todayPlan else {
            resolvedMeals = []
            return
        }
        let seedData = SeedDataLoader.shared
        guard let foodDB = seedData.foodDatabase else { return }

        resolvedMeals = plan.meals.map { storedMeal in
            let items = storedMeal.items.map { item -> ResolvedMealItem in
                let food = foodDB.food(byId: item.foodId)
                let nutrients = food?.nutrients(forRawWeight: item.weightRaw)
                let cooked = food?.cookedWeight(fromRawWeight: item.weightRaw) ?? item.weightRaw
                return ResolvedMealItem(
                    foodName: food?.name ?? item.foodId,
                    weightRaw: item.weightRaw,
                    weightCooked: cooked,
                    protein: nutrients?.protein ?? 0,
                    carb: nutrients?.carb ?? 0,
                    fat: nutrients?.fat ?? 0,
                    calories: nutrients?.calories ?? 0
                )
            }
            return ResolvedMeal(label: storedMeal.label, mealType: storedMeal.mealType, items: items)
        }
    }

    private func currentWeekStart() -> Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        return cal.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
    }
}

import Foundation
import SwiftData
import CycleEngine

/// Central data access layer wrapping SwiftData CRUD and CycleEngine computations.
@MainActor
final class DataRepository: Observable {
    private let modelContext: ModelContext
    private let seedData: SeedDataLoader

    init(modelContext: ModelContext, seedData: SeedDataLoader = .shared) {
        self.modelContext = modelContext
        self.seedData = seedData
        seedData.loadIfNeeded()
    }

    // MARK: - UserProfile

    func fetchProfile() -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        return try? modelContext.fetch(descriptor).first
    }

    func createOrUpdateProfile(
        height: Double,
        weight: Double,
        age: Int,
        gender: UserProfile.Gender,
        prBench: Double? = nil,
        prDeadlift: Double? = nil,
        prSquat: Double? = nil,
        proteinPerKg: Double = 2.2
    ) -> UserProfile {
        let profile: UserProfile
        if let existing = fetchProfile() {
            profile = existing
        } else {
            profile = UserProfile()
            modelContext.insert(profile)
        }
        profile.height = height
        profile.weight = weight
        profile.age = age
        profile.gender = gender
        profile.prBench = prBench
        profile.prDeadlift = prDeadlift
        profile.prSquat = prSquat
        profile.proteinPerKg = proteinPerKg
        profile.updatedAt = Date()
        return profile
    }

    // MARK: - Week Plan Generation

    /// Generate a 7-day plan starting from the given date, based on user profile and default template.
    func generateWeekPlan(startDate: Date) -> [DailyPlan] {
        guard let profile = fetchProfile(),
              let trainingTemplate = seedData.defaultTrainingTemplate,
              let mealTemplate = seedData.mealTemplate(for: trainingTemplate.id),
              let foodDB = seedData.foodDatabase else {
            return []
        }

        deleteExistingPlans(from: startDate, days: 7)

        let weekPlan = MealPlanGenerator.generate(mealTemplate: mealTemplate, foodDB: foodDB)
        let calendar = Calendar.current
        var plans: [DailyPlan] = []

        for generatedDay in weekPlan.days {
            guard let date = calendar.date(byAdding: .day, value: generatedDay.dayIndex, to: startDate) else {
                continue
            }
            let storedMeals = ModelMapping.toStoredMeals(from: generatedDay.meals)
            let plan = DailyPlan(
                date: date,
                dayIndex: generatedDay.dayIndex,
                carbType: ModelMapping.toLocalCarbType(generatedDay.carbType),
                targetCalories: generatedDay.macroTargets.calories,
                targetProtein: generatedDay.macroTargets.protein,
                targetCarb: generatedDay.macroTargets.carb,
                targetFat: generatedDay.macroTargets.fat,
                meals: storedMeals
            )
            modelContext.insert(plan)
            plans.append(plan)
        }

        return plans
    }

    private func deleteExistingPlans(from startDate: Date, days: Int) {
        let calendar = Calendar.current
        guard let endDate = calendar.date(byAdding: .day, value: days, to: startDate) else { return }
        let predicate = #Predicate<DailyPlan> { plan in
            plan.date >= startDate && plan.date < endDate
        }
        let descriptor = FetchDescriptor<DailyPlan>(predicate: predicate)
        if let existing = try? modelContext.fetch(descriptor) {
            for plan in existing {
                modelContext.delete(plan)
            }
        }
    }

    // MARK: - DailyPlan Queries

    func fetchTodayPlan() -> DailyPlan? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return nil }
        let predicate = #Predicate<DailyPlan> { plan in
            plan.date >= startOfDay && plan.date < endOfDay
        }
        let descriptor = FetchDescriptor<DailyPlan>(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }

    func fetchWeekPlans(from startDate: Date) -> [DailyPlan] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        guard let end = calendar.date(byAdding: .day, value: 7, to: start) else { return [] }
        let predicate = #Predicate<DailyPlan> { plan in
            plan.date >= start && plan.date < end
        }
        var descriptor = FetchDescriptor<DailyPlan>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.date)]
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Training & Meal Completion

    func markTrainingCompleted(_ plan: DailyPlan, feedback: DailyPlan.TrainingFeedback?) {
        plan.isTrainingCompleted = true
        plan.trainingFeedback = feedback
    }

    func markMealCompleted(_ plan: DailyPlan) {
        plan.isMealCompleted = true
    }

    // MARK: - Weight Records

    func recordWeight(weight: Double, bodyFat: Double? = nil, date: Date = Date()) -> WeightRecord {
        let record = WeightRecord(date: date, weight: weight, bodyFat: bodyFat)
        modelContext.insert(record)
        return record
    }

    func fetchWeightRecords(limit: Int = 30) -> [WeightRecord] {
        var descriptor = FetchDescriptor<WeightRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func latestWeight() -> WeightRecord? {
        fetchWeightRecords(limit: 1).first
    }

    // MARK: - Macro Validation

    func validateDayPlan(_ plan: DailyPlan) -> ValidationResult? {
        guard let foodDB = seedData.foodDatabase else { return nil }
        let engineMeals = ModelMapping.toEngineMeals(from: plan.meals)
        let target = ModelMapping.toMacroTargets(from: plan)
        return MacroValidator.validateDay(
            meals: engineMeals,
            target: target,
            foodDB: foodDB,
            dayIndex: plan.dayIndex
        )
    }

    // MARK: - Save

    func save() {
        try? modelContext.save()
    }
}

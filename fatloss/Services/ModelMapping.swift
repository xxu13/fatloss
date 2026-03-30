import Foundation
import CycleEngine

/// Bridges between CycleEngine value types and SwiftData persistence models.
enum ModelMapping {

    // MARK: - UserProfile <-> CycleEngine.UserParams

    static func toUserParams(from profile: UserProfile) -> UserParams {
        UserParams(
            height: profile.height,
            weight: profile.weight,
            age: profile.age,
            gender: profile.gender == .male ? .male : .female,
            proteinPerKg: profile.proteinPerKg
        )
    }

    // MARK: - DailyPlan.CarbTypeLocal <-> CycleEngine.CarbType

    static func toCarbType(_ local: DailyPlan.CarbTypeLocal) -> CarbType {
        switch local {
        case .low:        return .low
        case .mediumLow:  return .mediumLow
        case .medium:     return .medium
        case .mediumHigh: return .mediumHigh
        case .high:       return .high
        }
    }

    static func toLocalCarbType(_ engine: CarbType) -> DailyPlan.CarbTypeLocal {
        switch engine {
        case .low:        return .low
        case .mediumLow:  return .mediumLow
        case .medium:     return .medium
        case .mediumHigh: return .mediumHigh
        case .high:       return .high
        }
    }

    // MARK: - CycleEngine.Meal -> DailyPlan.StoredMeal

    static func toStoredMeals(from meals: [Meal]) -> [DailyPlan.StoredMeal] {
        meals.map { meal in
            DailyPlan.StoredMeal(
                mealType: meal.mealType.rawValue,
                label: meal.label,
                items: meal.items.map { item in
                    DailyPlan.StoredMealItem(foodId: item.foodId, weightRaw: item.weightRaw)
                }
            )
        }
    }

    // MARK: - DailyPlan.StoredMeal -> CycleEngine.Meal

    static func toEngineMeals(from stored: [DailyPlan.StoredMeal]) -> [Meal] {
        stored.compactMap { sm in
            guard let mealType = MealType(rawValue: sm.mealType) else { return nil }
            return Meal(
                mealType: mealType,
                label: sm.label,
                items: sm.items.map { MealItem(foodId: $0.foodId, weightRaw: $0.weightRaw) }
            )
        }
    }

    // MARK: - DailyPlan -> CycleEngine.MacroTargets

    static func toMacroTargets(from plan: DailyPlan) -> MacroTargets {
        MacroTargets(
            calories: plan.targetCalories,
            protein: plan.targetProtein,
            carb: plan.targetCarb,
            fat: plan.targetFat
        )
    }
}

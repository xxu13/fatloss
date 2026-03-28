import Foundation

public struct GeneratedDayPlan: Sendable {
    public var dayIndex: Int
    public var carbType: CarbType
    public var macroTargets: MacroTargets
    public var meals: [Meal]
    public var actualMacros: MacroTargets

    public init(dayIndex: Int, carbType: CarbType, macroTargets: MacroTargets, meals: [Meal], actualMacros: MacroTargets) {
        self.dayIndex = dayIndex
        self.carbType = carbType
        self.macroTargets = macroTargets
        self.meals = meals
        self.actualMacros = actualMacros
    }
}

public struct GeneratedWeekPlan: Sendable {
    public var days: [GeneratedDayPlan]
    public var totalCalories: Double

    public init(days: [GeneratedDayPlan]) {
        self.days = days
        self.totalCalories = days.reduce(0) { $0 + $1.actualMacros.calories }
    }
}

public enum MealPlanGenerator: Sendable {
    /// Load a week plan from template, resolving food IDs against the food database
    public static func generate(
        mealTemplate: MealTemplate,
        foodDB: FoodDatabase
    ) -> GeneratedWeekPlan {
        let days = mealTemplate.days.map { dayPlan -> GeneratedDayPlan in
            let actualMacros = calculateDayMacros(meals: dayPlan.meals, foodDB: foodDB)
            return GeneratedDayPlan(
                dayIndex: dayPlan.dayIndex,
                carbType: dayPlan.carbType,
                macroTargets: dayPlan.macroTargets,
                meals: dayPlan.meals,
                actualMacros: actualMacros
            )
        }
        return GeneratedWeekPlan(days: days)
    }

    /// Calculate total macros for a single day from its meals
    public static func calculateDayMacros(meals: [Meal], foodDB: FoodDatabase) -> MacroTargets {
        var total = MacroTargets(calories: 0, protein: 0, carb: 0, fat: 0)
        for meal in meals {
            let mealMacros = calculateMealMacros(items: meal.items, foodDB: foodDB)
            total.calories += mealMacros.calories
            total.protein += mealMacros.protein
            total.carb += mealMacros.carb
            total.fat += mealMacros.fat
        }
        return total
    }

    /// Calculate macros for a single meal
    public static func calculateMealMacros(items: [MealItem], foodDB: FoodDatabase) -> MacroTargets {
        var total = MacroTargets(calories: 0, protein: 0, carb: 0, fat: 0)
        for item in items {
            guard let food = foodDB.food(byId: item.foodId) else { continue }
            let n = food.nutrients(forRawWeight: item.weightRaw)
            total.calories += n.calories
            total.protein += n.protein
            total.carb += n.carb
            total.fat += n.fat
        }
        return total
    }
}

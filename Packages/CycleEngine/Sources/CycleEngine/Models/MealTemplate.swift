import Foundation

public enum MealType: String, Codable, Sendable {
    case breakfast
    case preworkout
    case lunch
    case dinner
    case nightSnack
}

public struct MealItem: Codable, Sendable, Equatable {
    public var foodId: String
    public var weightRaw: Double

    public init(foodId: String, weightRaw: Double) {
        self.foodId = foodId
        self.weightRaw = weightRaw
    }
}

public struct Meal: Codable, Sendable, Equatable {
    public var mealType: MealType
    public var label: String
    public var items: [MealItem]

    public init(mealType: MealType, label: String, items: [MealItem]) {
        self.mealType = mealType
        self.label = label
        self.items = items
    }
}

public struct DayMealPlan: Codable, Sendable, Equatable {
    public var dayIndex: Int
    public var carbType: CarbType
    public var macroTargets: MacroTargets
    public var meals: [Meal]

    public init(dayIndex: Int, carbType: CarbType, macroTargets: MacroTargets, meals: [Meal]) {
        self.dayIndex = dayIndex
        self.carbType = carbType
        self.macroTargets = macroTargets
        self.meals = meals
    }
}

public struct MealTemplate: Codable, Sendable, Identifiable {
    public var id: String
    public var name: String
    public var trainingTemplateId: String
    public var targetBodyWeight: Double
    public var proteinPerKg: Double
    public var dailyProteinTarget: Double
    public var isCustom: Bool
    public var weeklyCaloriesTarget: Double
    public var days: [DayMealPlan]
}

public struct MealTemplateFile: Codable, Sendable {
    public var version: Int
    public var updatedAt: String
    public var description: String
    public var templates: [MealTemplate]
}

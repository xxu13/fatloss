import Foundation

public struct ValidationDeviation: Sendable {
    public var field: String
    public var target: Double
    public var actual: Double
    public var deviationPercent: Double

    public init(field: String, target: Double, actual: Double) {
        self.field = field
        self.target = target
        self.actual = actual
        self.deviationPercent = target > 0 ? ((actual - target) / target) * 100.0 : 0
    }
}

public struct ValidationResult: Sendable {
    public var passed: Bool
    public var deviations: [ValidationDeviation]
    public var dayIndex: Int?

    public var summary: String {
        let items = deviations.map { d in
            "\(d.field): \(String(format: "%.1f", d.actual))/\(String(format: "%.1f", d.target)) (\(String(format: "%+.1f%%", d.deviationPercent)))"
        }
        let status = passed ? "PASS" : "FAIL"
        return "[\(status)] " + items.joined(separator: " | ")
    }

    public init(passed: Bool, deviations: [ValidationDeviation], dayIndex: Int? = nil) {
        self.passed = passed
        self.deviations = deviations
        self.dayIndex = dayIndex
    }
}

public enum MacroValidator: Sendable {
    public static let defaultProteinTolerance = 0.05
    public static let defaultCarbTolerance = 0.05
    public static let defaultFatTolerance = 0.10
    public static let defaultCalorieTolerance = 0.05

    /// Validate actual macros against target
    public static func validate(
        actual: MacroTargets,
        target: MacroTargets,
        proteinTolerance: Double = defaultProteinTolerance,
        carbTolerance: Double = defaultCarbTolerance,
        fatTolerance: Double = defaultFatTolerance,
        calorieTolerance: Double = defaultCalorieTolerance,
        dayIndex: Int? = nil
    ) -> ValidationResult {
        let deviations = [
            ValidationDeviation(field: "protein", target: target.protein, actual: actual.protein),
            ValidationDeviation(field: "carb", target: target.carb, actual: actual.carb),
            ValidationDeviation(field: "fat", target: target.fat, actual: actual.fat),
            ValidationDeviation(field: "calories", target: target.calories, actual: actual.calories),
        ]

        let passed = deviations.allSatisfy { d in
            let tolerance: Double
            switch d.field {
            case "protein":  tolerance = proteinTolerance
            case "carb":     tolerance = carbTolerance
            case "fat":      tolerance = fatTolerance
            case "calories": tolerance = calorieTolerance
            default:         tolerance = 0.05
            }
            return abs(d.deviationPercent) <= tolerance * 100.0
        }

        return ValidationResult(passed: passed, deviations: deviations, dayIndex: dayIndex)
    }

    /// Validate an entire day plan's meals against its macro targets
    public static func validateDay(
        meals: [Meal],
        target: MacroTargets,
        foodDB: FoodDatabase,
        dayIndex: Int? = nil
    ) -> ValidationResult {
        let actual = MealPlanGenerator.calculateDayMacros(meals: meals, foodDB: foodDB)
        return validate(actual: actual, target: target, dayIndex: dayIndex)
    }

    /// Validate all days in a week plan
    public static func validateWeekPlan(
        weekPlan: GeneratedWeekPlan
    ) -> [ValidationResult] {
        weekPlan.days.map { day in
            validate(actual: day.actualMacros, target: day.macroTargets, dayIndex: day.dayIndex)
        }
    }
}

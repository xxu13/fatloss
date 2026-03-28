import Foundation

public struct MacroTargets: Codable, Sendable, Equatable {
    public var calories: Double
    public var protein: Double
    public var carb: Double
    public var fat: Double

    public init(calories: Double, protein: Double, carb: Double, fat: Double) {
        self.calories = calories
        self.protein = protein
        self.carb = carb
        self.fat = fat
    }

    public var calculatedCalories: Double {
        protein * 4 + carb * 4 + fat * 9
    }
}

import Foundation

public enum MacroAllocator: Sendable {
    /// Calculate daily macro targets based on user params and carb coefficient
    public static func allocate(
        params: UserParams,
        carbCoefficient: Double,
        targetCalories: Double
    ) -> MacroTargets {
        let protein = params.proteinPerKg * params.weight
        let carb = carbCoefficient * params.weight
        let fatCalories = targetCalories - protein * 4.0 - carb * 4.0
        let fat = max(fatCalories / 9.0, 0)

        return MacroTargets(
            calories: targetCalories,
            protein: protein,
            carb: carb,
            fat: fat
        )
    }

    /// Auto-derive target calories from BMR, then allocate
    public static func allocate(
        params: UserParams,
        intensity: Intensity,
        carbCoefficient: Double
    ) -> MacroTargets {
        let bmr = BMRCalculator.calculate(params: params)
        let tdee = TDEECalculator.calculate(bmr: bmr, intensity: intensity)
        return allocate(params: params, carbCoefficient: carbCoefficient, targetCalories: tdee)
    }
}

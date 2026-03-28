import Foundation

public struct SwapSuggestion: Sendable {
    public var originalFoodId: String
    public var originalWeight: Double
    public var replacementFoodId: String
    public var replacementWeight: Double
    public var replacementFoodName: String
    public var note: String

    public init(originalFoodId: String, originalWeight: Double, replacementFoodId: String, replacementWeight: Double, replacementFoodName: String, note: String) {
        self.originalFoodId = originalFoodId
        self.originalWeight = originalWeight
        self.replacementFoodId = replacementFoodId
        self.replacementWeight = replacementWeight
        self.replacementFoodName = replacementFoodName
        self.note = note
    }
}

public enum FoodSwapCalculator: Sendable {
    /// Find equivalent swap suggestions for a food item from equivalentSwaps table
    public static func findSwaps(
        foodId: String,
        weightRaw: Double,
        foodDB: FoodDatabase
    ) -> [SwapSuggestion] {
        var suggestions: [SwapSuggestion] = []

        for (_, group) in foodDB.equivalentSwaps {
            if group.baseFood == foodId {
                let ratio = weightRaw / group.baseAmount
                for equiv in group.equivalents {
                    let name = foodDB.food(byId: equiv.foodId)?.name ?? equiv.foodId
                    suggestions.append(SwapSuggestion(
                        originalFoodId: foodId,
                        originalWeight: weightRaw,
                        replacementFoodId: equiv.foodId,
                        replacementWeight: equiv.amount * ratio,
                        replacementFoodName: name,
                        note: equiv.note ?? ""
                    ))
                }
            } else if let equiv = group.equivalents.first(where: { $0.foodId == foodId }) {
                let ratio = weightRaw / equiv.amount
                let baseName = foodDB.food(byId: group.baseFood)?.name ?? group.baseFood
                suggestions.append(SwapSuggestion(
                    originalFoodId: foodId,
                    originalWeight: weightRaw,
                    replacementFoodId: group.baseFood,
                    replacementWeight: group.baseAmount * ratio,
                    replacementFoodName: baseName,
                    note: "反向换算"
                ))
                for other in group.equivalents where other.foodId != foodId {
                    let otherName = foodDB.food(byId: other.foodId)?.name ?? other.foodId
                    suggestions.append(SwapSuggestion(
                        originalFoodId: foodId,
                        originalWeight: weightRaw,
                        replacementFoodId: other.foodId,
                        replacementWeight: other.amount * ratio,
                        replacementFoodName: otherName,
                        note: "交叉换算"
                    ))
                }
            }
        }

        return suggestions
    }

    /// Calculate equivalent weight for a direct nutrient-based swap
    public static func swapByNutrient(
        original: Food,
        replacement: Food,
        originalWeight: Double,
        nutrientKey: KeyPath<Nutrients, Double>
    ) -> Double {
        let originalNutrient = original.nutrientsPer100gRaw[keyPath: nutrientKey]
        let replacementNutrient = replacement.nutrientsPer100gRaw[keyPath: nutrientKey]
        guard replacementNutrient > 0 else { return 0 }
        return originalWeight * originalNutrient / replacementNutrient
    }
}

import Foundation

public struct Nutrients: Codable, Sendable, Equatable {
    public var protein: Double
    public var fat: Double
    public var carb: Double
    public var calories: Double

    public init(protein: Double, fat: Double, carb: Double, calories: Double) {
        self.protein = protein
        self.fat = fat
        self.carb = carb
        self.calories = calories
    }
}

public struct Food: Codable, Sendable, Equatable, Identifiable {
    public var id: String
    public var name: String
    public var category: String
    public var nutrientsPer100gRaw: Nutrients
    public var cookedRatio: Double
    public var cookedRatioNote: String?
    public var servingSize: Double?
    public var servingSizeUnit: String?
    public var servingSizeNote: String?
    public var isCustom: Bool

    public init(
        id: String,
        name: String,
        category: String,
        nutrientsPer100gRaw: Nutrients,
        cookedRatio: Double,
        cookedRatioNote: String? = nil,
        servingSize: Double? = nil,
        servingSizeUnit: String? = nil,
        servingSizeNote: String? = nil,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.nutrientsPer100gRaw = nutrientsPer100gRaw
        self.cookedRatio = cookedRatio
        self.cookedRatioNote = cookedRatioNote
        self.servingSize = servingSize
        self.servingSizeUnit = servingSizeUnit
        self.servingSizeNote = servingSizeNote
        self.isCustom = isCustom
    }

    public func nutrients(forRawWeight grams: Double) -> Nutrients {
        let ratio = grams / 100.0
        return Nutrients(
            protein: nutrientsPer100gRaw.protein * ratio,
            fat: nutrientsPer100gRaw.fat * ratio,
            carb: nutrientsPer100gRaw.carb * ratio,
            calories: nutrientsPer100gRaw.calories * ratio
        )
    }

    public func cookedWeight(fromRawWeight grams: Double) -> Double {
        grams * cookedRatio
    }
}

public struct EquivalentSwapEntry: Codable, Sendable, Equatable {
    public var foodId: String
    public var amount: Double
    public var note: String?
}

public struct EquivalentSwapGroup: Codable, Sendable, Equatable {
    public var description: String
    public var baseFood: String
    public var baseAmount: Double
    public var equivalents: [EquivalentSwapEntry]
}

public struct FoodDatabase: Codable, Sendable {
    public var version: Int
    public var dataSource: String
    public var updatedAt: String
    public var foods: [Food]
    public var equivalentSwaps: [String: EquivalentSwapGroup]

    public func food(byId id: String) -> Food? {
        foods.first { $0.id == id }
    }
}

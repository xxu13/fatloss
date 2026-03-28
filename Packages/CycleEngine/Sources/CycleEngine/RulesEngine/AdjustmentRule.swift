import Foundation

public struct RuleCondition: Codable, Sendable {
    public var type: String
    public var metric: String
    public var `operator`: String
    public var value: RuleConditionValue
    public var duration: Int?
    public var durationUnit: String?
    public var note: String?
}

public enum RuleConditionValue: Codable, Sendable {
    case int(Int)
    case double(Double)
    case stringArray([String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
        } else if let doubleVal = try? container.decode(Double.self) {
            self = .double(doubleVal)
        } else if let arr = try? container.decode([String].self) {
            self = .stringArray(arr)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode RuleConditionValue")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let v): try container.encode(v)
        case .double(let v): try container.encode(v)
        case .stringArray(let v): try container.encode(v)
        }
    }

    public var doubleValue: Double {
        switch self {
        case .int(let v): return Double(v)
        case .double(let v): return v
        case .stringArray: return 0
        }
    }
}

public struct RuleAction: Codable, Sendable {
    public var type: String
    public var target: String
    public var field: String
    public var adjustment: Double
    public var adjustmentUnit: String
    public var note: String?
}

public struct RuleLimits: Codable, Sendable {
    public var restDayMinCalories: Double?
    public var restDayMinFat: Double?
    public var highCarbDayMaxCarb: Double?
    public var mediumHighCarbDayMaxCarb: Double?
    public var lowCarbDayMinFat: Double?
    public var lowCarbDayMaxCarb: Double?
    public var note: String?
}

public struct AdjustmentRule: Codable, Sendable, Identifiable {
    public var id: String
    public var name: String
    public var description: String
    public var priority: Int
    public var enabled: Bool
    public var condition: RuleCondition
    public var actions: [RuleAction]
    public var limits: RuleLimits
    public var userMessage: String
}

public struct GlobalConfig: Codable, Sendable {
    public var proteinPerKg: Double
    public var proteinPerKgNote: String?
    public var minCalories: Double
    public var minCaloriesNote: String?
    public var maxCarbReductionPerWeek: Double
    public var maxCarbReductionPerWeekNote: String?
    public var maxCalorieAdjustPerWeek: Double
    public var maxCalorieAdjustPerWeekNote: String?
    public var weeklyWeightLossTarget: WeeklyWeightLossTarget
}

public struct WeeklyWeightLossTarget: Codable, Sendable {
    public var min: Double
    public var max: Double
    public var unit: String
    public var note: String?
}

public struct RulesFile: Codable, Sendable {
    public var version: Int
    public var updatedAt: String
    public var description: String
    public var globalConfig: GlobalConfig
    public var rules: [AdjustmentRule]
}

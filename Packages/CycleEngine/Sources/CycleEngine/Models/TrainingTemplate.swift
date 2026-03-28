import Foundation

public enum Intensity: String, Codable, Sendable {
    case rest
    case mediumLow
    case medium
    case mediumHigh
    case high
    case veryHigh
}

public enum CarbType: String, Codable, Sendable {
    case low
    case mediumLow
    case medium
    case mediumHigh
    case high
}

public struct TrainingDayPlan: Codable, Sendable, Equatable {
    public var dayIndex: Int
    public var dayLabel: String
    public var weekday: String
    public var name: String
    public var description: String
    public var intensity: Intensity
    public var carbType: CarbType
    public var carbCoefficient: Double
    public var isRestDay: Bool

    public init(
        dayIndex: Int, dayLabel: String, weekday: String, name: String,
        description: String, intensity: Intensity, carbType: CarbType,
        carbCoefficient: Double, isRestDay: Bool
    ) {
        self.dayIndex = dayIndex
        self.dayLabel = dayLabel
        self.weekday = weekday
        self.name = name
        self.description = description
        self.intensity = intensity
        self.carbType = carbType
        self.carbCoefficient = carbCoefficient
        self.isRestDay = isRestDay
    }
}

public struct TrainingTemplate: Codable, Sendable, Identifiable {
    public var id: String
    public var name: String
    public var description: String
    public var cycleDays: Int
    public var trainingDaysPerWeek: Int
    public var isCustom: Bool
    public var dayPlans: [TrainingDayPlan]
}

public struct TrainingTemplateFile: Codable, Sendable {
    public var version: Int
    public var updatedAt: String
    public var templates: [TrainingTemplate]
}

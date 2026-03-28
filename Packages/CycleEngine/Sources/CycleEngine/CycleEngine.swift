import Foundation

public enum CycleEngine: Sendable {
    public static let version = "1.0.0"

    /// Load food database from JSON data
    public static func loadFoodDatabase(from data: Data) throws -> FoodDatabase {
        try JSONDecoder().decode(FoodDatabase.self, from: data)
    }

    /// Load training templates from JSON data
    public static func loadTrainingTemplates(from data: Data) throws -> TrainingTemplateFile {
        try JSONDecoder().decode(TrainingTemplateFile.self, from: data)
    }

    /// Load meal templates from JSON data
    public static func loadMealTemplates(from data: Data) throws -> MealTemplateFile {
        try JSONDecoder().decode(MealTemplateFile.self, from: data)
    }

    /// Load adjustment rules from JSON data
    public static func loadRules(from data: Data) throws -> RulesFile {
        try JSONDecoder().decode(RulesFile.self, from: data)
    }
}

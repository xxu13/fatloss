import Foundation
import SwiftData

@Model
final class DailyPlan {
    var date: Date
    var dayIndex: Int
    var carbTypeRaw: String
    var targetCalories: Double
    var targetProtein: Double
    var targetCarb: Double
    var targetFat: Double
    var mealsData: Data?
    var isTrainingCompleted: Bool
    var isMealCompleted: Bool
    var trainingFeedbackRaw: String?

    var carbType: CarbTypeLocal {
        get { CarbTypeLocal(rawValue: carbTypeRaw) ?? .medium }
        set { carbTypeRaw = newValue.rawValue }
    }

    var trainingFeedback: TrainingFeedback? {
        get {
            guard let raw = trainingFeedbackRaw else { return nil }
            return TrainingFeedback(rawValue: raw)
        }
        set { trainingFeedbackRaw = newValue?.rawValue }
    }

    enum CarbTypeLocal: String, Codable, CaseIterable {
        case low, mediumLow, medium, mediumHigh, high

        var displayName: String {
            switch self {
            case .high:       return "高碳"
            case .mediumHigh: return "次高碳"
            case .medium:     return "中碳"
            case .mediumLow:  return "次低碳"
            case .low:        return "低碳"
            }
        }

        var tagColor: String {
            switch self {
            case .high:       return "green"
            case .mediumHigh: return "teal"
            case .medium:     return "blue"
            case .mediumLow:  return "orange"
            case .low:        return "red"
            }
        }
    }

    enum TrainingFeedback: String, Codable, CaseIterable {
        case good
        case fatigued

        var displayName: String {
            switch self {
            case .good:     return "状态良好"
            case .fatigued: return "感觉乏力"
            }
        }
    }

    /// Stored meal data, decoded as array of StoredMeal
    struct StoredMeal: Codable {
        var mealType: String
        var label: String
        var items: [StoredMealItem]
    }

    struct StoredMealItem: Codable {
        var foodId: String
        var weightRaw: Double
    }

    var meals: [StoredMeal] {
        get {
            guard let data = mealsData else { return [] }
            return (try? JSONDecoder().decode([StoredMeal].self, from: data)) ?? []
        }
        set {
            mealsData = try? JSONEncoder().encode(newValue)
        }
    }

    init(
        date: Date,
        dayIndex: Int,
        carbType: CarbTypeLocal,
        targetCalories: Double,
        targetProtein: Double,
        targetCarb: Double,
        targetFat: Double,
        meals: [StoredMeal] = []
    ) {
        self.date = date
        self.dayIndex = dayIndex
        self.carbTypeRaw = carbType.rawValue
        self.targetCalories = targetCalories
        self.targetProtein = targetProtein
        self.targetCarb = targetCarb
        self.targetFat = targetFat
        self.mealsData = try? JSONEncoder().encode(meals)
        self.isTrainingCompleted = false
        self.isMealCompleted = false
    }
}

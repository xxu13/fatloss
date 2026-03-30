import Foundation
import SwiftData

@Model
final class UserProfile {
    var height: Double
    var weight: Double
    var age: Int
    var genderRaw: String
    var prBench: Double?
    var prDeadlift: Double?
    var prSquat: Double?
    var proteinPerKg: Double
    var reminderHour: Int
    var reminderMinute: Int
    var createdAt: Date
    var updatedAt: Date

    var gender: Gender {
        get { Gender(rawValue: genderRaw) ?? .male }
        set { genderRaw = newValue.rawValue }
    }

    enum Gender: String, Codable, CaseIterable {
        case male
        case female

        var displayName: String {
            switch self {
            case .male: return "男"
            case .female: return "女"
            }
        }
    }

    init(
        height: Double = 175,
        weight: Double = 75,
        age: Int = 25,
        gender: Gender = .male,
        proteinPerKg: Double = 2.2,
        reminderHour: Int = 7,
        reminderMinute: Int = 0
    ) {
        self.height = height
        self.weight = weight
        self.age = age
        self.genderRaw = gender.rawValue
        self.proteinPerKg = proteinPerKg
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

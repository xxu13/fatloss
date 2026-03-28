import Foundation

public enum Gender: String, Codable, Sendable {
    case male
    case female
}

public struct UserParams: Codable, Sendable, Equatable {
    public var height: Double
    public var weight: Double
    public var age: Int
    public var gender: Gender
    public var proteinPerKg: Double

    public init(height: Double, weight: Double, age: Int, gender: Gender, proteinPerKg: Double = 2.2) {
        self.height = height
        self.weight = weight
        self.age = age
        self.gender = gender
        self.proteinPerKg = proteinPerKg
    }
}

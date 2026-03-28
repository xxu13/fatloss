import Foundation

public enum BMRCalculator: Sendable {
    /// Mifflin-St Jeor equation
    public static func calculate(params: UserParams) -> Double {
        let base = 10.0 * params.weight + 6.25 * params.height - 5.0 * Double(params.age)
        switch params.gender {
        case .male:   return base + 5.0
        case .female: return base - 161.0
        }
    }
}

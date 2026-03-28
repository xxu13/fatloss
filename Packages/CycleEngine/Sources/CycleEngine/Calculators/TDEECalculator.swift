import Foundation

public enum TDEECalculator: Sendable {
    public static func activityFactor(for intensity: Intensity) -> Double {
        switch intensity {
        case .rest:       return 1.2
        case .mediumLow:  return 1.55
        case .medium:     return 1.55
        case .mediumHigh: return 1.65
        case .high:       return 1.725
        case .veryHigh:   return 1.725
        }
    }

    public static func calculate(bmr: Double, intensity: Intensity) -> Double {
        bmr * activityFactor(for: intensity)
    }
}

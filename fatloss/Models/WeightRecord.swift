import Foundation
import SwiftData

@Model
final class WeightRecord {
    var date: Date
    var weight: Double
    var bodyFat: Double?

    init(date: Date = Date(), weight: Double, bodyFat: Double? = nil) {
        self.date = date
        self.weight = weight
        self.bodyFat = bodyFat
    }
}

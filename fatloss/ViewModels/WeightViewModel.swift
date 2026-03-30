import Foundation
import SwiftData

@Observable
@MainActor
final class WeightViewModel {
    var records: [WeightRecord] = []
    var inputWeight: String = ""
    var inputBodyFat: String = ""
    var showingInput = false

    private var repo: DataRepository?

    func load(repo: DataRepository) {
        self.repo = repo
        refresh()
    }

    func refresh() {
        guard let repo else { return }
        records = repo.fetchWeightRecords(limit: 90)
    }

    func addRecord() {
        guard let repo, let weight = Double(inputWeight), weight > 0 else { return }
        let bodyFat = Double(inputBodyFat)
        _ = repo.recordWeight(weight: weight, bodyFat: bodyFat)
        repo.save()
        inputWeight = ""
        inputBodyFat = ""
        showingInput = false
        refresh()
    }

    var latestWeight: Double? {
        records.first?.weight
    }

    var weightTrend: [WeightRecord] {
        Array(records.reversed())
    }

    var isInputValid: Bool {
        guard let w = Double(inputWeight), w > 20 && w < 300 else { return false }
        if let bf = Double(inputBodyFat), (bf < 1 || bf > 60) { return false }
        return true
    }
}

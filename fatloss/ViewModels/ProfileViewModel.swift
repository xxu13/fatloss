import Foundation
import SwiftData
import CycleEngine

@Observable
@MainActor
final class ProfileViewModel {
    var height: Double = 175
    var weight: Double = 91
    var age: Int = 25
    var gender: UserProfile.Gender = .male
    var prBench: String = ""
    var prDeadlift: String = ""
    var prSquat: String = ""
    var proteinPerKg: Double = 2.2

    var hasExistingProfile = false

    private var repo: DataRepository?

    func load(repo: DataRepository) {
        self.repo = repo
        if let profile = repo.fetchProfile() {
            height = profile.height
            weight = profile.weight
            age = profile.age
            gender = profile.gender
            prBench = profile.prBench.map { String(format: "%.1f", $0) } ?? ""
            prDeadlift = profile.prDeadlift.map { String(format: "%.1f", $0) } ?? ""
            prSquat = profile.prSquat.map { String(format: "%.1f", $0) } ?? ""
            proteinPerKg = profile.proteinPerKg
            hasExistingProfile = true
        }
    }

    func save() {
        guard let repo else { return }
        _ = repo.createOrUpdateProfile(
            height: height,
            weight: weight,
            age: age,
            gender: gender,
            prBench: Double(prBench),
            prDeadlift: Double(prDeadlift),
            prSquat: Double(prSquat),
            proteinPerKg: proteinPerKg
        )
        repo.save()
        hasExistingProfile = true
    }

    var isValid: Bool {
        height > 0 && weight > 0 && age > 0
    }
}

import Foundation
import CycleEngine

/// Loads seed data from the app bundle's Resources/Data/ directory.
/// All public data (foods, templates, rules) is read-only and cached in memory.
@MainActor
final class SeedDataLoader: Observable {
    static let shared = SeedDataLoader()

    private(set) var foodDatabase: FoodDatabase?
    private(set) var trainingTemplates: [TrainingTemplate] = []
    private(set) var mealTemplates: [MealTemplate] = []
    private(set) var rulesFile: RulesFile?

    private var isLoaded = false

    private init() {}

    func loadIfNeeded() {
        guard !isLoaded else { return }
        loadFoods()
        loadTrainingTemplates()
        loadMealTemplates()
        loadRules()
        isLoaded = true
    }

    private func loadFoods() {
        guard let data = loadBundleJSON("foods") else { return }
        foodDatabase = try? CycleEngine.loadFoodDatabase(from: data)
    }

    private func loadTrainingTemplates() {
        guard let data = loadBundleJSON("training_templates") else { return }
        if let file = try? CycleEngine.loadTrainingTemplates(from: data) {
            trainingTemplates = file.templates
        }
    }

    private func loadMealTemplates() {
        guard let data = loadBundleJSON("meal_templates") else { return }
        if let file = try? CycleEngine.loadMealTemplates(from: data) {
            mealTemplates = file.templates
        }
    }

    private func loadRules() {
        guard let data = loadBundleJSON("rules") else { return }
        rulesFile = try? CycleEngine.loadRules(from: data)
    }

    private func loadBundleJSON(_ name: String) -> Data? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json", subdirectory: "Data") else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    // MARK: - Convenience accessors

    func food(byId id: String) -> Food? {
        foodDatabase?.food(byId: id)
    }

    var defaultTrainingTemplate: TrainingTemplate? {
        trainingTemplates.first
    }

    func mealTemplate(for trainingTemplateId: String) -> MealTemplate? {
        mealTemplates.first { $0.trainingTemplateId == trainingTemplateId }
    }

    var adjustmentRules: [AdjustmentRule] {
        rulesFile?.rules ?? []
    }

    var globalConfig: GlobalConfig? {
        rulesFile?.globalConfig
    }
}

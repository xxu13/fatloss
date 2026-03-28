import Testing
import Foundation
@testable import CycleEngine

func loadTestData(_ filename: String) throws -> Data {
    let url = Bundle.module.url(forResource: "TestData/\(filename)", withExtension: nil)!
    return try Data(contentsOf: url)
}

@Suite("JSON Decoding Tests")
struct DecodingTests {
    @Test func decodeFoodDatabase() throws {
        let data = try loadTestData("foods.json")
        let db = try CycleEngine.loadFoodDatabase(from: data)
        #expect(db.foods.count == 8)
        #expect(db.food(byId: "chicken-breast") != nil)
        #expect(db.food(byId: "chicken-breast")!.nutrientsPer100gRaw.protein == 24.6)
        #expect(db.food(byId: "dry-rice")!.nutrientsPer100gRaw.carb == 77.2)
        #expect(db.food(byId: "cooking-oil")!.nutrientsPer100gRaw.fat == 99.9)
    }

    @Test func decodeTrainingTemplates() throws {
        let data = try loadTestData("training_templates.json")
        let file = try CycleEngine.loadTrainingTemplates(from: data)
        #expect(file.templates.count == 1)
        let template = file.templates[0]
        #expect(template.id == "bench-press-5day")
        #expect(template.dayPlans.count == 7)
        #expect(template.dayPlans[0].carbCoefficient == 4.0)
        #expect(template.dayPlans[3].intensity == .veryHigh)
        #expect(template.dayPlans[5].isRestDay == true)
    }

    @Test func decodeMealTemplates() throws {
        let data = try loadTestData("meal_templates.json")
        let file = try CycleEngine.loadMealTemplates(from: data)
        #expect(file.templates.count == 1)
        let template = file.templates[0]
        #expect(template.days.count == 7)
        #expect(template.targetBodyWeight == 91)
        #expect(template.dailyProteinTarget == 200)
    }

    @Test func decodeRules() throws {
        let data = try loadTestData("rules.json")
        let file = try CycleEngine.loadRules(from: data)
        #expect(file.rules.count == 5)
        #expect(file.globalConfig.proteinPerKg == 2.2)
        #expect(file.globalConfig.minCalories == 1800)
    }
}

@Suite("BMR Calculator Tests")
struct BMRTests {
    let maleParams = UserParams(height: 175, weight: 91, age: 28, gender: .male)
    let femaleParams = UserParams(height: 165, weight: 60, age: 25, gender: .female)

    @Test func maleBMR() {
        let bmr = BMRCalculator.calculate(params: maleParams)
        // 10*91 + 6.25*175 - 5*28 + 5 = 910 + 1093.75 - 140 + 5 = 1868.75
        #expect(abs(bmr - 1868.75) < 0.01)
    }

    @Test func femaleBMR() {
        let bmr = BMRCalculator.calculate(params: femaleParams)
        // 10*60 + 6.25*165 - 5*25 - 161 = 600 + 1031.25 - 125 - 161 = 1345.25
        #expect(abs(bmr - 1345.25) < 0.01)
    }
}

@Suite("TDEE Calculator Tests")
struct TDEETests {
    @Test func activityFactors() {
        #expect(TDEECalculator.activityFactor(for: .rest) == 1.2)
        #expect(TDEECalculator.activityFactor(for: .high) == 1.725)
        #expect(TDEECalculator.activityFactor(for: .veryHigh) == 1.725)
    }

    @Test func tdeeCalculation() {
        let bmr = 1868.75
        let tdee = TDEECalculator.calculate(bmr: bmr, intensity: .high)
        #expect(abs(tdee - 1868.75 * 1.725) < 0.01)
    }
}

@Suite("Macro Allocator Tests")
struct MacroAllocatorTests {
    let params = UserParams(height: 175, weight: 91, age: 28, gender: .male)

    @Test func day1Allocation() {
        let macros = MacroAllocator.allocate(
            params: params,
            carbCoefficient: 4.0,
            targetCalories: 3000
        )
        // protein = 2.2 * 91 = 200.2
        #expect(abs(macros.protein - 200.2) < 0.1)
        // carb = 4.0 * 91 = 364
        #expect(abs(macros.carb - 364) < 0.1)
        // fat = (3000 - 200.2*4 - 364*4) / 9 = (3000 - 800.8 - 1456) / 9 = 743.2/9 = 82.58
        #expect(abs(macros.fat - 82.58) < 0.1)
    }

    @Test func restDayAllocation() {
        let macros = MacroAllocator.allocate(
            params: params,
            carbCoefficient: 0.9,
            targetCalories: 2300
        )
        // protein = 200.2, carb = 0.9*91 = 81.9
        #expect(abs(macros.protein - 200.2) < 0.1)
        #expect(abs(macros.carb - 81.9) < 0.1)
        // fat = (2300 - 200.2*4 - 81.9*4) / 9 = (2300 - 800.8 - 327.6) / 9 = 1171.6/9 = 130.18
        #expect(abs(macros.fat - 130.18) < 0.1)
    }
}

@Suite("Food Nutrient Calculation Tests")
struct FoodNutrientTests {
    @Test func chickenBreast150g() {
        let food = Food(
            id: "chicken-breast", name: "去皮鸡胸肉", category: "protein",
            nutrientsPer100gRaw: Nutrients(protein: 24.6, fat: 1.9, carb: 0, calories: 116),
            cookedRatio: 0.75
        )
        let n = food.nutrients(forRawWeight: 150)
        #expect(abs(n.protein - 36.9) < 0.01)
        #expect(abs(n.fat - 2.85) < 0.01)
        #expect(n.carb == 0)
        #expect(abs(n.calories - 174.0) < 0.01)
    }

    @Test func dryRice180g() {
        let food = Food(
            id: "dry-rice", name: "干大米", category: "carb",
            nutrientsPer100gRaw: Nutrients(protein: 7.4, fat: 0.8, carb: 77.2, calories: 346),
            cookedRatio: 2.8
        )
        let n = food.nutrients(forRawWeight: 180)
        #expect(abs(n.protein - 13.32) < 0.01)
        #expect(abs(n.carb - 138.96) < 0.01)
        #expect(abs(n.calories - 622.8) < 0.01)
    }

    @Test func cookedWeight() {
        let food = Food(
            id: "dry-rice", name: "干大米", category: "carb",
            nutrientsPer100gRaw: Nutrients(protein: 7.4, fat: 0.8, carb: 77.2, calories: 346),
            cookedRatio: 2.8
        )
        #expect(abs(food.cookedWeight(fromRawWeight: 180) - 504) < 0.01)
    }
}

@Suite("Meal Plan Macro Validation Tests")
struct MealPlanValidationTests {
    var foodDB: FoodDatabase!

    init() throws {
        let data = try loadTestData("foods.json")
        foodDB = try CycleEngine.loadFoodDatabase(from: data)
    }

    @Test func validateDay1Macros() throws {
        let data = try loadTestData("meal_templates.json")
        let file = try CycleEngine.loadMealTemplates(from: data)
        let day = file.templates[0].days[0]

        let actual = MealPlanGenerator.calculateDayMacros(meals: day.meals, foodDB: foodDB)
        let result = MacroValidator.validate(actual: actual, target: day.macroTargets, dayIndex: 0)

        for d in result.deviations {
            #expect(abs(d.deviationPercent) <= 10.0, "Day1 \(d.field) deviation \(d.deviationPercent)% exceeds 10%")
        }
    }

    @Test func validateAllDaysMacros() throws {
        let data = try loadTestData("meal_templates.json")
        let file = try CycleEngine.loadMealTemplates(from: data)
        let weekPlan = MealPlanGenerator.generate(mealTemplate: file.templates[0], foodDB: foodDB)

        let results = MacroValidator.validateWeekPlan(weekPlan: weekPlan)
        for result in results {
            for d in result.deviations {
                #expect(abs(d.deviationPercent) <= 10.0,
                    "Day\(result.dayIndex ?? -1) \(d.field) deviation \(d.deviationPercent)% exceeds 10%")
            }
        }
    }

    @Test func validateWeeklyCalories() throws {
        let data = try loadTestData("meal_templates.json")
        let file = try CycleEngine.loadMealTemplates(from: data)
        let weekPlan = MealPlanGenerator.generate(mealTemplate: file.templates[0], foodDB: foodDB)

        let targetWeekly = file.templates[0].weeklyCaloriesTarget
        let deviation = abs(weekPlan.totalCalories - targetWeekly) / targetWeekly * 100
        #expect(deviation <= 5.0, "Weekly calories deviation \(deviation)% exceeds 5%")
    }
}

@Suite("Food Swap Tests")
struct FoodSwapTests {
    var foodDB: FoodDatabase!

    init() throws {
        let data = try loadTestData("foods.json")
        foodDB = try CycleEngine.loadFoodDatabase(from: data)
    }

    @Test func swapChickenForBeef() {
        let swaps = FoodSwapCalculator.findSwaps(foodId: "chicken-breast", weightRaw: 100, foodDB: foodDB)
        #expect(!swaps.isEmpty)
        let beefSwap = swaps.first { $0.replacementFoodId == "lean-beef" }
        #expect(beefSwap != nil)
        #expect(abs(beefSwap!.replacementWeight - 111) < 0.1)
    }

    @Test func swapByProtein() {
        let chicken = foodDB.food(byId: "chicken-breast")!
        let fish = foodDB.food(byId: "fish-fillet")!
        let weight = FoodSwapCalculator.swapByNutrient(
            original: chicken, replacement: fish,
            originalWeight: 150, nutrientKey: \.protein
        )
        // 150 * 24.6 / 18.0 = 205
        #expect(abs(weight - 205) < 0.1)
    }
}

@Suite("Rules Engine Tests")
struct RulesEngineTests {
    var rules: [AdjustmentRule]!

    init() throws {
        let data = try loadTestData("rules.json")
        let file = try CycleEngine.loadRules(from: data)
        rules = file.rules
    }

    @Test func weightPlateauTriggersRule() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 28, gender: .male),
            weeklyWeightChanges: [0.1, 0.0]
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        let plateau = applications.first { $0.ruleId == "weight-plateau" }
        #expect(plateau != nil)
    }

    @Test func trainingFatigueTriggersRule() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 28, gender: .male),
            consecutiveFatigueCount: 3
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        let fatigue = applications.first { $0.ruleId == "training-fatigue" }
        #expect(fatigue != nil)
    }

    @Test func ageRuleTriggersForOlderUser() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 35, gender: .male)
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        let ageRule = applications.first { $0.ruleId == "age-adjustment" }
        #expect(ageRule != nil)
    }

    @Test func ageRuleDoesNotTriggerForYoungUser() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 28, gender: .male)
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        let ageRule = applications.first { $0.ruleId == "age-adjustment" }
        #expect(ageRule == nil)
    }

    @Test func rapidWeightLossTriggersProtection() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 28, gender: .male),
            weeklyWeightChanges: [-1.5]
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        let rapid = applications.first { $0.ruleId == "rapid-weight-loss" }
        #expect(rapid != nil)
    }

    @Test func noRulesTriggeredForHealthyState() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 28, gender: .male),
            weeklyWeightChanges: [-0.7],
            consecutiveFatigueCount: 0
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        #expect(applications.isEmpty, "Healthy state should not trigger any rules")
    }

    @Test func multipleRulesCanFireSimultaneously() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 35, gender: .male),
            weeklyWeightChanges: [0.1, 0.0],
            consecutiveFatigueCount: 2
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        let ids = Set(applications.map { $0.ruleId })
        #expect(ids.contains("weight-plateau"))
        #expect(ids.contains("training-fatigue"))
        #expect(ids.contains("age-adjustment"))
    }

    @Test func rulesAreSortedByPriority() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 35, gender: .male),
            weeklyWeightChanges: [0.1, 0.0],
            consecutiveFatigueCount: 2
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        #expect(applications.count >= 2)
        let plateauIdx = applications.firstIndex { $0.ruleId == "weight-plateau" }!
        let ageIdx = applications.firstIndex { $0.ruleId == "age-adjustment" }!
        #expect(plateauIdx < ageIdx, "Priority 1 rules should fire before priority 3")
    }

    @Test func hungerSymptomTriggersRule() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 28, gender: .male),
            symptoms: ["persistentHunger"],
            symptomDurationDays: 3
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        let hunger = applications.first { $0.ruleId == "hunger-insomnia" }
        #expect(hunger != nil)
    }

    @Test func hungerSymptomDoesNotTriggerIfTooShort() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 28, gender: .male),
            symptoms: ["persistentHunger"],
            symptomDurationDays: 1
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        let hunger = applications.first { $0.ruleId == "hunger-insomnia" }
        #expect(hunger == nil, "Duration too short, should not trigger")
    }
}

@Suite("Rules Engine Apply Adjustments Tests")
struct RulesApplyTests {
    var foodDB: FoodDatabase!
    var mealTemplate: MealTemplate!
    var trainingTemplate: TrainingTemplate!
    var rules: [AdjustmentRule]!

    init() throws {
        foodDB = try CycleEngine.loadFoodDatabase(from: loadTestData("foods.json"))
        mealTemplate = try CycleEngine.loadMealTemplates(from: loadTestData("meal_templates.json")).templates[0]
        trainingTemplate = try CycleEngine.loadTrainingTemplates(from: loadTestData("training_templates.json")).templates[0]
        rules = try CycleEngine.loadRules(from: loadTestData("rules.json")).rules
    }

    @Test func applyWeightPlateauReducesRestDayCalories() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 28, gender: .male),
            weeklyWeightChanges: [0.1, 0.0]
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        let adjusted = RulesEngine.applyAdjustments(
            dayPlans: mealTemplate.days,
            applications: applications,
            trainingDayPlans: trainingTemplate.dayPlans
        )

        let restDay5 = adjusted[5]
        let original5 = mealTemplate.days[5]
        #expect(restDay5.macroTargets.calories < original5.macroTargets.calories,
            "Rest day calories should decrease after plateau rule")

        let trainingDay0 = adjusted[0]
        let original0 = mealTemplate.days[0]
        #expect(trainingDay0.macroTargets.calories == original0.macroTargets.calories,
            "Training day calories should not change from plateau rule")
    }

    @Test func applyAgeRuleReducesAllDayCalories() {
        let context = RuleEvaluationContext(
            userParams: UserParams(height: 175, weight: 91, age: 35, gender: .male)
        )
        let applications = RulesEngine.evaluate(rules: rules, context: context)
        let adjusted = RulesEngine.applyAdjustments(
            dayPlans: mealTemplate.days,
            applications: applications,
            trainingDayPlans: trainingTemplate.dayPlans
        )

        for i in 0..<7 {
            #expect(adjusted[i].macroTargets.calories < mealTemplate.days[i].macroTargets.calories,
                "Day\(i) calories should decrease after age rule")
        }
    }
}

@Suite("Per-Day Detailed Macro Validation")
struct PerDayValidationTests {
    var foodDB: FoodDatabase!
    var mealTemplate: MealTemplate!

    init() throws {
        foodDB = try CycleEngine.loadFoodDatabase(from: loadTestData("foods.json"))
        mealTemplate = try CycleEngine.loadMealTemplates(from: loadTestData("meal_templates.json")).templates[0]
    }

    @Test func day0MediumHighCarbDay() throws {
        let day = mealTemplate.days[0]
        #expect(day.carbType == .mediumHigh)
        let actual = MealPlanGenerator.calculateDayMacros(meals: day.meals, foodDB: foodDB)
        let result = MacroValidator.validate(actual: actual, target: day.macroTargets, dayIndex: 0)
        for d in result.deviations {
            #expect(abs(d.deviationPercent) <= 5.0,
                "Day0 \(d.field): actual=\(String(format:"%.1f", d.actual)) target=\(String(format:"%.1f", d.target)) dev=\(String(format:"%.1f%%", d.deviationPercent))")
        }
    }

    @Test func day1MediumCarbDay() throws {
        let day = mealTemplate.days[1]
        #expect(day.carbType == .medium)
        let actual = MealPlanGenerator.calculateDayMacros(meals: day.meals, foodDB: foodDB)
        let result = MacroValidator.validate(actual: actual, target: day.macroTargets, dayIndex: 1)
        for d in result.deviations {
            #expect(abs(d.deviationPercent) <= 5.0,
                "Day1 \(d.field): actual=\(String(format:"%.1f", d.actual)) target=\(String(format:"%.1f", d.target)) dev=\(String(format:"%.1f%%", d.deviationPercent))")
        }
    }

    @Test func day2MediumLowCarbDay() throws {
        let day = mealTemplate.days[2]
        #expect(day.carbType == .mediumLow)
        let actual = MealPlanGenerator.calculateDayMacros(meals: day.meals, foodDB: foodDB)
        let result = MacroValidator.validate(actual: actual, target: day.macroTargets, dayIndex: 2)
        for d in result.deviations {
            #expect(abs(d.deviationPercent) <= 5.0,
                "Day2 \(d.field): actual=\(String(format:"%.1f", d.actual)) target=\(String(format:"%.1f", d.target)) dev=\(String(format:"%.1f%%", d.deviationPercent))")
        }
    }

    @Test func day3HighCarbDay() throws {
        let day = mealTemplate.days[3]
        #expect(day.carbType == .high)
        let actual = MealPlanGenerator.calculateDayMacros(meals: day.meals, foodDB: foodDB)
        let result = MacroValidator.validate(actual: actual, target: day.macroTargets, dayIndex: 3)
        for d in result.deviations {
            #expect(abs(d.deviationPercent) <= 5.0,
                "Day3 \(d.field): actual=\(String(format:"%.1f", d.actual)) target=\(String(format:"%.1f", d.target)) dev=\(String(format:"%.1f%%", d.deviationPercent))")
        }
    }

    @Test func day4MediumHighCarbDay() throws {
        let day = mealTemplate.days[4]
        #expect(day.carbType == .mediumHigh)
        let actual = MealPlanGenerator.calculateDayMacros(meals: day.meals, foodDB: foodDB)
        let result = MacroValidator.validate(actual: actual, target: day.macroTargets, dayIndex: 4)
        for d in result.deviations {
            #expect(abs(d.deviationPercent) <= 5.0,
                "Day4 \(d.field): actual=\(String(format:"%.1f", d.actual)) target=\(String(format:"%.1f", d.target)) dev=\(String(format:"%.1f%%", d.deviationPercent))")
        }
    }

    @Test func day5LowCarbRestDay() throws {
        let day = mealTemplate.days[5]
        #expect(day.carbType == .low)
        let actual = MealPlanGenerator.calculateDayMacros(meals: day.meals, foodDB: foodDB)
        let result = MacroValidator.validate(actual: actual, target: day.macroTargets, dayIndex: 5)
        for d in result.deviations {
            #expect(abs(d.deviationPercent) <= 5.0,
                "Day5 \(d.field): actual=\(String(format:"%.1f", d.actual)) target=\(String(format:"%.1f", d.target)) dev=\(String(format:"%.1f%%", d.deviationPercent))")
        }
    }

    @Test func day6LowCarbRestDay() throws {
        let day = mealTemplate.days[6]
        #expect(day.carbType == .low)
        let actual = MealPlanGenerator.calculateDayMacros(meals: day.meals, foodDB: foodDB)
        let result = MacroValidator.validate(actual: actual, target: day.macroTargets, dayIndex: 6)
        for d in result.deviations {
            #expect(abs(d.deviationPercent) <= 5.0,
                "Day6 \(d.field): actual=\(String(format:"%.1f", d.actual)) target=\(String(format:"%.1f", d.target)) dev=\(String(format:"%.1f%%", d.deviationPercent))")
        }
    }

    @Test func proteinConsistencyAcrossAllDays() throws {
        for day in mealTemplate.days {
            let actual = MealPlanGenerator.calculateDayMacros(meals: day.meals, foodDB: foodDB)
            #expect(abs(actual.protein - 200) / 200.0 * 100.0 <= 5.0,
                "Day\(day.dayIndex) protein \(String(format:"%.1f", actual.protein))g should be near 200g")
        }
    }
}

@Suite("Edge Cases and Boundary Tests")
struct EdgeCaseTests {
    @Test func zeroWeightNutrients() {
        let food = Food(
            id: "test", name: "test", category: "test",
            nutrientsPer100gRaw: Nutrients(protein: 24.6, fat: 1.9, carb: 0, calories: 116),
            cookedRatio: 0.75
        )
        let n = food.nutrients(forRawWeight: 0)
        #expect(n.protein == 0)
        #expect(n.fat == 0)
        #expect(n.carb == 0)
        #expect(n.calories == 0)
    }

    @Test func macroTargetsCalculatedCalories() {
        let macros = MacroTargets(calories: 3000, protein: 200, carb: 365, fat: 82)
        let calc = macros.calculatedCalories
        // 200*4 + 365*4 + 82*9 = 800 + 1460 + 738 = 2998
        #expect(abs(calc - 2998) < 0.01)
    }

    @Test func validationWithZeroTarget() {
        let actual = MacroTargets(calories: 100, protein: 10, carb: 5, fat: 5)
        let target = MacroTargets(calories: 0, protein: 0, carb: 0, fat: 0)
        let result = MacroValidator.validate(actual: actual, target: target)
        #expect(result.passed)
    }

    @Test func unknownFoodIdIsSkippedInMealCalc() throws {
        let data = try loadTestData("foods.json")
        let foodDB = try CycleEngine.loadFoodDatabase(from: data)
        let items = [
            MealItem(foodId: "nonexistent-food", weightRaw: 100),
            MealItem(foodId: "chicken-breast", weightRaw: 100)
        ]
        let macros = MealPlanGenerator.calculateMealMacros(items: items, foodDB: foodDB)
        #expect(abs(macros.protein - 24.6) < 0.01, "Only chicken-breast should be counted")
    }

    @Test func foodSwapWithZeroNutrient() throws {
        let food1 = Food(
            id: "a", name: "a", category: "test",
            nutrientsPer100gRaw: Nutrients(protein: 10, fat: 0, carb: 0, calories: 40),
            cookedRatio: 1.0
        )
        let food2 = Food(
            id: "b", name: "b", category: "test",
            nutrientsPer100gRaw: Nutrients(protein: 0, fat: 5, carb: 0, calories: 45),
            cookedRatio: 1.0
        )
        let weight = FoodSwapCalculator.swapByNutrient(
            original: food1, replacement: food2,
            originalWeight: 100, nutrientKey: \.protein
        )
        #expect(weight == 0, "Cannot swap by protein when replacement has 0 protein")
    }

    @Test func foodSwapReverseDirection() throws {
        let data = try loadTestData("foods.json")
        let foodDB = try CycleEngine.loadFoodDatabase(from: data)
        let swaps = FoodSwapCalculator.findSwaps(foodId: "lean-beef", weightRaw: 111, foodDB: foodDB)
        let chickenSwap = swaps.first { $0.replacementFoodId == "chicken-breast" }
        #expect(chickenSwap != nil)
        #expect(abs(chickenSwap!.replacementWeight - 100) < 1.0)
    }

    @Test func carbSwapRiceToFlour() throws {
        let data = try loadTestData("foods.json")
        let foodDB = try CycleEngine.loadFoodDatabase(from: data)
        let swaps = FoodSwapCalculator.findSwaps(foodId: "dry-rice", weightRaw: 100, foodDB: foodDB)
        let flourSwap = swaps.first { $0.replacementFoodId == "dry-flour" }
        #expect(flourSwap != nil)
        #expect(abs(flourSwap!.replacementWeight - 105) < 0.1)
    }
}

@Suite("Full Cycle Integration Tests")
struct IntegrationTests {
    var foodDB: FoodDatabase!
    var mealTemplate: MealTemplate!
    var trainingTemplate: TrainingTemplate!

    init() throws {
        foodDB = try CycleEngine.loadFoodDatabase(from: loadTestData("foods.json"))
        mealTemplate = try CycleEngine.loadMealTemplates(from: loadTestData("meal_templates.json")).templates[0]
        trainingTemplate = try CycleEngine.loadTrainingTemplates(from: loadTestData("training_templates.json")).templates[0]
    }

    @Test func fullCycleBMRToValidation() {
        let params = UserParams(height: 175, weight: 91, age: 28, gender: .male)
        let bmr = BMRCalculator.calculate(params: params)
        #expect(bmr > 1500 && bmr < 2500)

        for dayPlan in trainingTemplate.dayPlans {
            let tdee = TDEECalculator.calculate(bmr: bmr, intensity: dayPlan.intensity)
            #expect(tdee > bmr, "TDEE should always be greater than BMR")

            let macros = MacroAllocator.allocate(
                params: params,
                carbCoefficient: dayPlan.carbCoefficient,
                targetCalories: mealTemplate.days[dayPlan.dayIndex].macroTargets.calories
            )
            #expect(macros.protein > 150, "Protein should be substantial")
            #expect(macros.fat > 0, "Fat should never be negative")
        }
    }

    @Test func weekPlanGenerationAndValidation() {
        let weekPlan = MealPlanGenerator.generate(mealTemplate: mealTemplate, foodDB: foodDB)
        #expect(weekPlan.days.count == 7)

        let results = MacroValidator.validateWeekPlan(weekPlan: weekPlan)
        #expect(results.count == 7)

        let failedDays = results.filter { !$0.passed }
        #expect(failedDays.count == 0, "All days should pass validation within default tolerances")
    }

    @Test func trainingAndMealTemplateAlignment() {
        for i in 0..<7 {
            let training = trainingTemplate.dayPlans[i]
            let meal = mealTemplate.days[i]
            #expect(training.dayIndex == meal.dayIndex)
            #expect(training.carbType == meal.carbType,
                "Day\(i) carbType mismatch: training=\(training.carbType) meal=\(meal.carbType)")
        }
    }

    @Test func highCarbDayHasMoreCarbsThanLowCarbDay() {
        let highCarbDay = mealTemplate.days.first { $0.carbType == .high }!
        let lowCarbDay = mealTemplate.days.first { $0.carbType == .low }!
        #expect(highCarbDay.macroTargets.carb > lowCarbDay.macroTargets.carb * 3,
            "High carb day should have significantly more carbs than low carb day")
    }

    @Test func restDaysHaveFewerCalories() {
        let trainingDaysCals = mealTemplate.days.filter { $0.carbType != .low }.map { $0.macroTargets.calories }
        let restDaysCals = mealTemplate.days.filter { $0.carbType == .low }.map { $0.macroTargets.calories }
        let avgTraining = trainingDaysCals.reduce(0, +) / Double(trainingDaysCals.count)
        let avgRest = restDaysCals.reduce(0, +) / Double(restDaysCals.count)
        #expect(avgRest < avgTraining, "Rest days should have fewer calories than training days")
    }
}

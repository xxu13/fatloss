import Foundation

public struct RuleEvaluationContext: Sendable {
    public var userParams: UserParams
    public var weeklyWeightChanges: [Double]
    public var consecutiveFatigueCount: Int
    public var symptoms: [String]
    public var symptomDurationDays: Int

    public init(
        userParams: UserParams,
        weeklyWeightChanges: [Double] = [],
        consecutiveFatigueCount: Int = 0,
        symptoms: [String] = [],
        symptomDurationDays: Int = 0
    ) {
        self.userParams = userParams
        self.weeklyWeightChanges = weeklyWeightChanges
        self.consecutiveFatigueCount = consecutiveFatigueCount
        self.symptoms = symptoms
        self.symptomDurationDays = symptomDurationDays
    }
}

public struct RuleApplication: Sendable {
    public var ruleId: String
    public var ruleName: String
    public var actions: [RuleAction]
    public var userMessage: String

    public init(ruleId: String, ruleName: String, actions: [RuleAction], userMessage: String) {
        self.ruleId = ruleId
        self.ruleName = ruleName
        self.actions = actions
        self.userMessage = userMessage
    }
}

public enum RulesEngine: Sendable {
    /// Evaluate all rules against the current context, return triggered rule applications
    public static func evaluate(
        rules: [AdjustmentRule],
        context: RuleEvaluationContext
    ) -> [RuleApplication] {
        let enabledRules = rules.filter { $0.enabled }.sorted { $0.priority < $1.priority }
        var applications: [RuleApplication] = []

        for rule in enabledRules {
            if evaluateCondition(rule.condition, context: context) {
                applications.append(RuleApplication(
                    ruleId: rule.id,
                    ruleName: rule.name,
                    actions: rule.actions,
                    userMessage: rule.userMessage
                ))
            }
        }

        return applications
    }

    /// Apply rule adjustments to a set of day plans
    public static func applyAdjustments(
        dayPlans: [DayMealPlan],
        applications: [RuleApplication],
        trainingDayPlans: [TrainingDayPlan]
    ) -> [DayMealPlan] {
        var adjusted = dayPlans

        for application in applications {
            for action in application.actions {
                adjusted = applyAction(action, to: adjusted, trainingDayPlans: trainingDayPlans)
            }
        }

        return adjusted
    }

    static func evaluateCondition(_ condition: RuleCondition, context: RuleEvaluationContext) -> Bool {
        switch condition.type {
        case "weightTrend":
            return evaluateWeightTrend(condition, context: context)
        case "trainingFeedback":
            return evaluateTrainingFeedback(condition, context: context)
        case "userProfile":
            return evaluateUserProfile(condition, context: context)
        case "userFeedback":
            return evaluateUserFeedback(condition, context: context)
        default:
            return false
        }
    }

    static func evaluateWeightTrend(_ condition: RuleCondition, context: RuleEvaluationContext) -> Bool {
        let duration = condition.duration ?? 1
        guard context.weeklyWeightChanges.count >= duration else { return false }
        let recent = Array(context.weeklyWeightChanges.suffix(duration))
        let threshold = condition.value.doubleValue
        return recent.allSatisfy { compare($0, condition.operator, threshold) }
    }

    static func evaluateTrainingFeedback(_ condition: RuleCondition, context: RuleEvaluationContext) -> Bool {
        let threshold = Int(condition.value.doubleValue)
        return compare(Double(context.consecutiveFatigueCount), condition.operator, Double(threshold))
    }

    static func evaluateUserProfile(_ condition: RuleCondition, context: RuleEvaluationContext) -> Bool {
        let metricValue: Double
        switch condition.metric {
        case "age":    metricValue = Double(context.userParams.age)
        case "weight": metricValue = context.userParams.weight
        case "height": metricValue = context.userParams.height
        default:       return false
        }
        return compare(metricValue, condition.operator, condition.value.doubleValue)
    }

    static func evaluateUserFeedback(_ condition: RuleCondition, context: RuleEvaluationContext) -> Bool {
        guard case .stringArray(let values) = condition.value else { return false }
        let duration = condition.duration ?? 1
        guard context.symptomDurationDays >= duration else { return false }
        return context.symptoms.contains { values.contains($0) }
    }

    static func compare(_ lhs: Double, _ op: String, _ rhs: Double) -> Bool {
        switch op {
        case ">=": return lhs >= rhs
        case "<=": return lhs <= rhs
        case ">":  return lhs > rhs
        case "<":  return lhs < rhs
        case "==": return abs(lhs - rhs) < 0.001
        default:   return false
        }
    }

    static func applyAction(_ action: RuleAction, to dayPlans: [DayMealPlan], trainingDayPlans: [TrainingDayPlan]) -> [DayMealPlan] {
        dayPlans.enumerated().map { (index, plan) in
            guard shouldApplyTo(target: action.target, dayPlan: plan, trainingDayPlan: trainingDayPlans.first(where: { $0.dayIndex == plan.dayIndex })) else {
                return plan
            }
            var adjusted = plan
            switch action.field {
            case "calories": adjusted.macroTargets.calories += action.adjustment
            case "protein":  adjusted.macroTargets.protein += action.adjustment
            case "carb":     adjusted.macroTargets.carb += action.adjustment
            case "fat":      adjusted.macroTargets.fat += action.adjustment
            default: break
            }
            return adjusted
        }
    }

    static func shouldApplyTo(target: String, dayPlan: DayMealPlan, trainingDayPlan: TrainingDayPlan?) -> Bool {
        switch target {
        case "allDays":
            return true
        case "trainingDays":
            return !(trainingDayPlan?.isRestDay ?? true)
        case "restDays":
            return trainingDayPlan?.isRestDay ?? false
        case "highCarbDays":
            return dayPlan.carbType == .high
        case "mediumHighCarbDays":
            return dayPlan.carbType == .mediumHigh
        case "lowCarbDays":
            return dayPlan.carbType == .low
        default:
            return false
        }
    }
}

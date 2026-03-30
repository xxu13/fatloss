import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = TodayViewModel()
    @State private var showFeedbackSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if let plan = vm.todayPlan {
                    todayContent(plan)
                } else {
                    ContentUnavailableView(
                        "暂无计划",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("请先完成个人档案设置")
                    )
                }
            }
            .navigationTitle("今日计划")
            .onAppear {
                vm.load(repo: DataRepository(modelContext: modelContext))
            }
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private func todayContent(_ plan: DailyPlan) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                macroSummaryCard(plan)
                trainingCard(plan)
                mealsSection
            }
            .padding()
        }
    }

    // MARK: - Macro Summary Card

    private func macroSummaryCard(_ plan: DailyPlan) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(plan.carbType.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(carbTypeColor(plan.carbType).opacity(0.15))
                    .foregroundStyle(carbTypeColor(plan.carbType))
                    .clipShape(Capsule())

                Spacer()

                Text("\(Int(plan.targetCalories)) kcal")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            HStack(spacing: 0) {
                macroColumn(label: "蛋白质", value: plan.targetProtein, unit: "g", color: .red)
                Spacer()
                macroColumn(label: "碳水", value: plan.targetCarb, unit: "g", color: .orange)
                Spacer()
                macroColumn(label: "脂肪", value: plan.targetFat, unit: "g", color: .yellow)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func macroColumn(label: String, value: Double, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(value))")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(height: 3)
                .frame(maxWidth: 60)
        }
    }

    // MARK: - Training Card

    private func trainingCard(_ plan: DailyPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: plan.isTrainingCompleted ? "checkmark.circle.fill" : "dumbbell")
                    .foregroundStyle(plan.isTrainingCompleted ? .green : .accentColor)
                Text(vm.trainingDayPlan?.name ?? "训练")
                    .font(.headline)
                Spacer()
                if plan.isTrainingCompleted {
                    Text("已完成")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            if let training = vm.trainingDayPlan {
                Text(training.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !plan.isTrainingCompleted {
                Button {
                    showFeedbackSheet = true
                } label: {
                    Text("标记训练完成")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            if let feedback = plan.trainingFeedback {
                HStack {
                    Image(systemName: feedback == .good ? "hand.thumbsup" : "battery.25percent")
                    Text(feedback.displayName)
                        .font(.caption)
                }
                .foregroundStyle(feedback == .good ? .green : .orange)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showFeedbackSheet) {
            trainingFeedbackSheet
        }
    }

    private var trainingFeedbackSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("今天训练感觉如何？")
                    .font(.title3)
                    .fontWeight(.semibold)

                VStack(spacing: 12) {
                    Button {
                        vm.markTrainingDone(feedback: .good)
                        showFeedbackSheet = false
                    } label: {
                        Label("状态良好", systemImage: "hand.thumbsup")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button {
                        vm.markTrainingDone(feedback: .fatigued)
                        showFeedbackSheet = false
                    } label: {
                        Label("感觉乏力", systemImage: "battery.25percent")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)

                    Button {
                        vm.markTrainingDone(feedback: nil)
                        showFeedbackSheet = false
                    } label: {
                        Text("跳过反馈")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            .padding()
            .presentationDetents([.height(280)])
        }
    }

    // MARK: - Meals Section

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("饮食清单")
                    .font(.headline)
                Spacer()
                if let plan = vm.todayPlan, !plan.isMealCompleted {
                    Button("标记饮食完成") {
                        vm.markMealDone()
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                } else if vm.todayPlan?.isMealCompleted == true {
                    Label("已完成", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            ForEach(vm.resolvedMeals) { meal in
                mealCard(meal)
            }
        }
    }

    private func mealCard(_ meal: TodayViewModel.ResolvedMeal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(meal.label)
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach(meal.items) { item in
                HStack {
                    Text(item.foodName)
                        .font(.subheadline)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(item.weightRaw))g 生重")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        if item.weightCooked != item.weightRaw {
                            Text("约 \(Int(item.weightCooked))g 熟重")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            let mealP = meal.items.reduce(0.0) { $0 + $1.protein }
            let mealC = meal.items.reduce(0.0) { $0 + $1.carb }
            let mealF = meal.items.reduce(0.0) { $0 + $1.fat }
            let mealK = meal.items.reduce(0.0) { $0 + $1.calories }

            HStack {
                Text("P \(Int(mealP))g")
                Text("C \(Int(mealC))g")
                Text("F \(Int(mealF))g")
                Spacer()
                Text("\(Int(mealK)) kcal")
                    .fontWeight(.medium)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Helpers

    private func carbTypeColor(_ type: DailyPlan.CarbTypeLocal) -> Color {
        switch type {
        case .high:       return .green
        case .mediumHigh: return .teal
        case .medium:     return .blue
        case .mediumLow:  return .orange
        case .low:        return .red
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [UserProfile.self, DailyPlan.self, WeightRecord.self], inMemory: true)
}

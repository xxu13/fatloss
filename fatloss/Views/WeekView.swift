import SwiftUI
import SwiftData

struct WeekView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = WeekViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.weekPlans.isEmpty {
                    ContentUnavailableView(
                        "暂无周计划",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("请先完成个人档案设置")
                    )
                } else {
                    weekContent
                }
            }
            .navigationTitle("周计划")
            .onAppear {
                vm.load(repo: DataRepository(modelContext: modelContext))
            }
        }
    }

    private var weekContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vm.weekPlans, id: \.dayIndex) { plan in
                    dayCard(plan)
                }

                weekSummary
            }
            .padding()
        }
    }

    private func dayCard(_ plan: DailyPlan) -> some View {
        let training = vm.trainingInfo(for: plan.dayIndex)
        let isToday = Calendar.current.isDateInToday(plan.date)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(dayLabel(plan.date))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        if isToday {
                            Text("TODAY")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(training?.name ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(plan.carbType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(carbColor(plan.carbType).opacity(0.12))
                    .foregroundStyle(carbColor(plan.carbType))
                    .clipShape(Capsule())
            }

            HStack {
                miniMacro(label: "P", value: plan.targetProtein, color: .red)
                miniMacro(label: "C", value: plan.targetCarb, color: .orange)
                miniMacro(label: "F", value: plan.targetFat, color: .yellow)
                Spacer()
                Text("\(Int(plan.targetCalories)) kcal")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            HStack(spacing: 12) {
                statusBadge(
                    icon: plan.isTrainingCompleted ? "checkmark.circle.fill" : "circle",
                    text: "训练",
                    done: plan.isTrainingCompleted
                )
                statusBadge(
                    icon: plan.isMealCompleted ? "checkmark.circle.fill" : "circle",
                    text: "饮食",
                    done: plan.isMealCompleted
                )
            }
        }
        .padding()
        .background(isToday ? Color.accentColor.opacity(0.06) : Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday ? Color.accentColor.opacity(0.3) : .clear, lineWidth: 1)
        )
    }

    private func miniMacro(label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("\(label) \(Int(value))g")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func statusBadge(icon: String, text: String, done: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(done ? .green : .gray)
            Text(text)
                .font(.caption2)
                .foregroundStyle(done ? .primary : .secondary)
        }
    }

    private var weekSummary: some View {
        let totalKcal = vm.weekPlans.reduce(0.0) { $0 + $1.targetCalories }
        let totalP = vm.weekPlans.reduce(0.0) { $0 + $1.targetProtein }
        return VStack(spacing: 8) {
            Divider()
            HStack {
                Text("周总计")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("P \(Int(totalP))g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Int(totalKcal)) kcal")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Helpers

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "E M/d"
        return formatter.string(from: date)
    }

    private func carbColor(_ type: DailyPlan.CarbTypeLocal) -> Color {
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
    WeekView()
        .modelContainer(for: [UserProfile.self, DailyPlan.self, WeightRecord.self], inMemory: true)
}

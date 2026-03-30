import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showProfileEdit = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                profileSection
                planSection
                aboutSection
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showProfileEdit) {
                ProfileEditView()
            }
        }
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        Section("个人档案") {
            if let p = profile {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(p.gender.displayName)  \(p.age) 岁")
                            .font(.subheadline)
                        Text("\(String(format: "%.1f", p.height)) cm / \(String(format: "%.1f", p.weight)) kg")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("编辑") {
                        showProfileEdit = true
                    }
                    .font(.subheadline)
                }

                if let bench = p.prBench, let dead = p.prDeadlift, let squat = p.prSquat {
                    HStack {
                        Text("三大项 PR")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("B \(Int(bench)) / D \(Int(dead)) / S \(Int(squat)) kg")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Text("蛋白质摄入")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(String(format: "%.1f", p.proteinPerKg)) g/kg")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button("创建档案") {
                    showProfileEdit = true
                }
            }
        }
    }

    // MARK: - Plan Section

    private var planSection: some View {
        Section("计划") {
            HStack {
                Text("训练模板")
                Spacer()
                Text(SeedDataLoader.shared.defaultTrainingTemplate?.name ?? "--")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("食材库")
                Spacer()
                let count = SeedDataLoader.shared.foodDatabase?.foods.count ?? 0
                Text("\(count) 种食材")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section("关于") {
            HStack {
                Text("版本")
                Spacer()
                Text("1.0.0 (MVP)")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("CycleEngine")
                Spacer()
                Text("v1.0.0")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("数据来源")
                Spacer()
                Text("中国食物成分表 第6版")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserProfile.self, DailyPlan.self, WeightRecord.self], inMemory: true)
}

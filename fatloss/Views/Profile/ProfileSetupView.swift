import SwiftUI
import SwiftData

struct ProfileSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = ProfileViewModel()
    @State private var currentStep = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator

                TabView(selection: $currentStep) {
                    basicInfoStep.tag(0)
                    bodyInfoStep.tag(1)
                    liftingStep.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                bottomButtons
            }
            .navigationTitle("初始设置")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    // MARK: - Step 1: Basic Info

    private var basicInfoStep: some View {
        Form {
            Section("基本信息") {
                Picker("性别", selection: $vm.gender) {
                    ForEach(UserProfile.Gender.allCases, id: \.self) { g in
                        Text(g.displayName).tag(g)
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Text("年龄")
                    Spacer()
                    TextField("25", value: $vm.age, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("岁")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Step 2: Body Info

    private var bodyInfoStep: some View {
        Form {
            Section("身体数据") {
                HStack {
                    Text("身高")
                    Spacer()
                    TextField("175", value: $vm.height, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("cm")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("体重")
                    Spacer()
                    TextField("91", value: $vm.weight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("kg")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("蛋白质/kg")
                    Spacer()
                    TextField("2.2", value: $vm.proteinPerKg, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("g")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Step 3: Lifting PRs (Optional)

    private var liftingStep: some View {
        Form {
            Section("三大项 PR（可选）") {
                HStack {
                    Text("卧推")
                    Spacer()
                    TextField("--", text: $vm.prBench)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("kg")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("硬拉")
                    Spacer()
                    TextField("--", text: $vm.prDeadlift)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("kg")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("深蹲")
                    Spacer()
                    TextField("--", text: $vm.prSquat)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("kg")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Text("三大项数据为选填，可随时在设置中修改。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("上一步") {
                    currentStep -= 1
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            if currentStep < 2 {
                Button("下一步") {
                    currentStep += 1
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("完成设置") {
                    vm.load(repo: DataRepository(modelContext: modelContext))
                    vm.save()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.isValid)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

#Preview {
    ProfileSetupView()
        .modelContainer(for: [UserProfile.self, DailyPlan.self, WeightRecord.self], inMemory: true)
}

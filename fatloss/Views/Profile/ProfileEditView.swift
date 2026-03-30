import SwiftUI
import SwiftData

struct ProfileEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var vm = ProfileViewModel()

    var body: some View {
        NavigationStack {
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
                        Text("岁").foregroundStyle(.secondary)
                    }
                }

                Section("身体数据") {
                    HStack {
                        Text("身高")
                        Spacer()
                        TextField("175", value: $vm.height, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("cm").foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("体重")
                        Spacer()
                        TextField("91", value: $vm.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("kg").foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("蛋白质/kg")
                        Spacer()
                        TextField("2.2", value: $vm.proteinPerKg, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g").foregroundStyle(.secondary)
                    }
                }

                Section("三大项 PR（可选）") {
                    HStack {
                        Text("卧推")
                        Spacer()
                        TextField("--", text: $vm.prBench)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("kg").foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("硬拉")
                        Spacer()
                        TextField("--", text: $vm.prDeadlift)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("kg").foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("深蹲")
                        Spacer()
                        TextField("--", text: $vm.prSquat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("kg").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("编辑档案")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        vm.save()
                        dismiss()
                    }
                    .disabled(!vm.isValid)
                }
            }
            .onAppear {
                vm.load(repo: DataRepository(modelContext: modelContext))
            }
        }
    }
}

#Preview {
    ProfileEditView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}

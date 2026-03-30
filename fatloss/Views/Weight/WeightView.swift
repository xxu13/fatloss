import SwiftUI
import SwiftData
import Charts

struct WeightView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = WeightViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    latestWeightCard
                    chartSection
                    recordsList
                }
                .padding()
            }
            .navigationTitle("体重记录")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        vm.showingInput = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $vm.showingInput) {
                weightInputSheet
            }
            .onAppear {
                vm.load(repo: DataRepository(modelContext: modelContext))
            }
        }
    }

    // MARK: - Latest Weight

    private var latestWeightCard: some View {
        VStack(spacing: 8) {
            if let latest = vm.latestWeight {
                Text(String(format: "%.1f", latest))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                Text("kg")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            } else {
                Text("--")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text("尚未记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("趋势")
                .font(.headline)

            if vm.weightTrend.count >= 2 {
                Chart(vm.weightTrend, id: \.date) { record in
                    LineMark(
                        x: .value("日期", record.date),
                        y: .value("体重", record.weight)
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("日期", record.date),
                        y: .value("体重", record.weight)
                    )
                    .symbolSize(30)
                }
                .chartYScale(domain: chartYDomain)
                .frame(height: 200)
                .padding(.vertical, 8)
            } else {
                Text("记录至少 2 次体重后显示趋势图")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var chartYDomain: ClosedRange<Double> {
        let weights = vm.weightTrend.map(\.weight)
        let minW = (weights.min() ?? 80) - 2
        let maxW = (weights.max() ?? 100) + 2
        return minW...maxW
    }

    // MARK: - Records List

    private var recordsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("历史记录")
                .font(.headline)

            if vm.records.isEmpty {
                Text("暂无记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(vm.records, id: \.date) { record in
                    HStack {
                        Text(dateLabel(record.date))
                            .font(.subheadline)
                        Spacer()
                        if let bf = record.bodyFat {
                            Text("体脂 \(String(format: "%.1f", bf))%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(String(format: "%.1f kg", record.weight))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 6)
                    Divider()
                }
            }
        }
    }

    // MARK: - Weight Input Sheet

    private var weightInputSheet: some View {
        NavigationStack {
            Form {
                Section("体重") {
                    HStack {
                        TextField("输入体重", text: $vm.inputWeight)
                            .keyboardType(.decimalPad)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("体脂率（可选）") {
                    HStack {
                        TextField("--", text: $vm.inputBodyFat)
                            .keyboardType(.decimalPad)
                        Text("%")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("记录体重")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        vm.showingInput = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        vm.addRecord()
                    }
                    .disabled(!vm.isInputValid)
                }
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Helpers

    private func dateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M/d E"
        return formatter.string(from: date)
    }
}

#Preview {
    WeightView()
        .modelContainer(for: [UserProfile.self, DailyPlan.self, WeightRecord.self], inMemory: true)
}

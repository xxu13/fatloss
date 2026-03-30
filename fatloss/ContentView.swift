import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("碳循环减脂计划助手")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Phase 3 将替换为 TabView 导航")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, DailyPlan.self, WeightRecord.self], inMemory: true)
}

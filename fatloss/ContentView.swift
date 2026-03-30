import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    var body: some View {
        if profiles.isEmpty {
            ProfileSetupView()
        } else {
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, DailyPlan.self, WeightRecord.self], inMemory: true)
}

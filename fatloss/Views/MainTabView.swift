import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("今日", systemImage: "flame")
                }

            WeekView()
                .tabItem {
                    Label("周计划", systemImage: "calendar")
                }

            WeightView()
                .tabItem {
                    Label("体重", systemImage: "scalemass")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [UserProfile.self, DailyPlan.self, WeightRecord.self], inMemory: true)
}

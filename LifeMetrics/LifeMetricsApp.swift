//
//  LifeMetricsApp.swift
//  LifeMetrics
//
//  Created by centrix on 2026/2/21.
//

import SwiftUI
import SwiftData

@main
struct LifeMetricsApp: App {
    // 配置 SwiftData 模型容器
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WeeklyPlan.self,
            TaskItem.self,
            RewardItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("无法创建 SwiftData ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView() // 启动后进入全局导航页
        }
        .modelContainer(sharedModelContainer) // 将数据库注入全局环境
    }
}

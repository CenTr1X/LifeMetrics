//
//  MainTabView.swift
//  LifeMetrics
//
//  Created by centrix on 2026/2/21.
//


import SwiftUI
import SwiftData

struct MainTabView: View {
    // 控制当前选中的 Tab
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // 1. 工作台 (我们刚刚写好的高颜值仪表盘)
            DashboardView()
                .tabItem {
                    Label("工作台", systemImage: "gauge.with.needle")
                }
                .tag(0)
            
            // 2. 任务执行页 (真实页面)
            TaskListView()
                .tabItem {
                    Label("打卡", systemImage: "checkmark.circle.fill")
                }
                .tag(1)
            
            // 3. 计划配置页 (占位)
            WeeklyPlanViewPlaceholder()
                .tabItem {
                    Label("计划", systemImage: "calendar.badge.clock")
                }
                .tag(2)
            
            // 4. 数据复盘页 (占位)
            ReviewViewPlaceholder()
                .tabItem {
                    Label("复盘", systemImage: "chart.xyaxis.line")
                }
                .tag(3)
        }
        // 强制使用原生的深色/浅色自适应主题，让 TabBar 更显质感
        .tint(.indigo) 
    }
}

// MARK: - 以下为方便项目直接编译运行的“占位视图”，后续我们会逐个替换为真实页面

struct TaskListViewPlaceholder: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "timer")
                    .font(.system(size: 60))
                    .foregroundColor(.indigo)
                Text("任务打卡与专注计时器")
                    .font(.title2).bold()
                Text("这里将展示您本周的具体任务列表，\n并提供一键开启番茄钟打卡的功能。")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("执行打卡")
        }
    }
}

struct WeeklyPlanViewPlaceholder: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                Text("周预算与任务分配")
                    .font(.title2).bold()
                Text("在这里动态调整每周的 3600 分钟预算，\n为各项专业和拓展学习分配预期时间。")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("周计划配置")
        }
    }
}

struct ReviewViewPlaceholder: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                Text("自动化周复盘")
                    .font(.title2).bold()
                Text("每周日晚自动生成图表，对比计划与实际耗时，\n计算您的职级升降与经验值。")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("数据复盘")
        }
    }
}

// MARK: - 预览代码 (在 Xcode 右侧直接看效果)
#Preview {
    MainTabView()
        // 注入内存数据库，仅供预览不影响本地真实数据
        .modelContainer(for: [WeeklyPlan.self, TaskItem.self, RewardItem.self], inMemory: true)
}

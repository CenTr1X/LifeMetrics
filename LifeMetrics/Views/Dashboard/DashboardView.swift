//
//  DashboardView.swift
//  LifeMetrics
//
//  Created by centrix on 2026/2/21.
//


import SwiftUI
import SwiftData
import UIKit

struct DashboardView: View {
    // 从数据库中查询所有的周计划，按周次倒序排列（最新的在最上面）
    @Query(sort: \WeeklyPlan.weekNumber, order: .reverse) private var plans: [WeeklyPlan]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let currentPlan = plans.first {
                    VStack(spacing: 24) {
                        // 1. 核心数据卡片
                        LevelCardView(plan: currentPlan)
                            .padding(.horizontal)
                        
                        // 2. 三大分类同心环 (类似 Apple Fitness)
                        VStack {
                            Text("精力分布")
                                .font(.title3)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ZStack {
                                // 最外圈：专业学习 (蓝色)
                                ProgressRingView(
                                    progress: calculateProgress(for: .professional, in: currentPlan),
                                    color: TaskCategory.professional.themeColor,
                                    lineWidth: 22
                                )
                                .frame(width: 240, height: 240)
                                
                                // 中圈：拓展学习 (橙色)
                                ProgressRingView(
                                    progress: calculateProgress(for: .extended, in: currentPlan),
                                    color: TaskCategory.extended.themeColor,
                                    lineWidth: 22
                                )
                                .frame(width: 180, height: 180)
                                
                                // 内圈：阅读积累 (绿色)
                                ProgressRingView(
                                    progress: calculateProgress(for: .reading, in: currentPlan),
                                    color: TaskCategory.reading.themeColor,
                                    lineWidth: 22
                                )
                                .frame(width: 120, height: 120)
                                
                                // 中心图标或奖励分提示
                                VStack {
                                    Image(systemName: "flame.fill")
                                        .font(.title)
                                        .foregroundColor(.red)
                                    Text("奖励项")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 20)
                            
                            // 图例
                            HStack(spacing: 20) {
                                LegendItem(category: .professional)
                                LegendItem(category: .extended)
                                LegendItem(category: .reading)
                            }
                        }
                        .padding(.vertical)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                } else {
                    // 数据库为空时的空状态提示
                    ContentUnavailableView(
                        "暂无计划",
                        systemImage: "calendar.badge.plus",
                        description: Text("点击下方按钮开启你的第一周计划")
                    )
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("指挥中心")
            .toolbar {
                // 仅供测试：快速添加假数据
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addMockData) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }
    
    // 辅助计算单个分类的进度百分比
    private func calculateProgress(for category: TaskCategory, in plan: WeeklyPlan) -> Double {
        let categoryTasks = plan.tasks.filter { $0.categoryRawValue == category.rawValue }
        let planned = categoryTasks.reduce(0) { $0 + $1.plannedMinutes }
        let actual = categoryTasks.reduce(0) { $0 + $1.actualMinutes }
        
        guard planned > 0 else { return 0.0 }
        return Double(actual) / Double(planned)
    }
    
    // 生成测试数据 (方便您在 Xcode Preview 里看到效果)
    private func addMockData() {
        let newPlan = WeeklyPlan(weekNumber: (plans.first?.weekNumber ?? 0) + 1, startDate: Date(), endDate: Date().addingTimeInterval(86400*7), attendanceBudget: 3600)
        
        // 模拟添加您的数据
        let profTask = TaskItem(name: "软考备考", category: .professional, plannedMinutes: 1200, actualMinutes: 810)
        let extTask = TaskItem(name: "金融学基础", category: .extended, plannedMinutes: 600, actualMinutes: 237)
        let readTask = TaskItem(name: "阅读积累", category: .reading, plannedMinutes: 420, actualMinutes: 268)
        let reward = RewardItem(name: "跑步强度", amount: 9, score: 450)
        
        newPlan.tasks.append(contentsOf: [profTask, extTask, readTask])
        newPlan.rewards.append(reward)
        
        modelContext.insert(newPlan)
    }
}

// 环形图底部的小图例组件
struct LegendItem: View {
    let category: TaskCategory
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(category.themeColor)
                .frame(width: 10, height: 10)
            Text(category.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

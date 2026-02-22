//
//  WeeklyPlan.swift
//  LifeMetrics
//
//  Created by centrix on 2026/2/21.
//


import SwiftData
import Foundation

@Model
class WeeklyPlan {
    @Attribute(.unique) var weekNumber: Int // 周次
    var startDate: Date
    var endDate: Date
    var attendanceBudget: Double // 周预算时长
    var previousTotalScore: Double // 历史累计分值
    
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.weeklyPlan)
    var tasks: [TaskItem] = []
    
    @Relationship(deleteRule: .cascade, inverse: \RewardItem.weeklyPlan)
    var rewards: [RewardItem] = []
    
    init(weekNumber: Int, startDate: Date, endDate: Date, attendanceBudget: Double = 3600.0) {
        self.weekNumber = weekNumber
        self.startDate = startDate
        self.endDate = endDate
        self.attendanceBudget = attendanceBudget
        self.previousTotalScore = 0.0
    }
    
    // 动态计算：实际总完成时长
    @Transient var totalActualMinutes: Int {
        tasks.reduce(0) { $0 + $1.actualMinutes }
    }
    
    // 动态计算：实际完成总权重 (主线任务 + 支线奖励)
    @Transient var totalActualWeight: Double {
        let taskWeight = tasks.reduce(0.0) { $0 + $1.calculatedWeight }
        let rewardScore = rewards.reduce(0.0) { $0 + $1.score }
        return taskWeight + rewardScore
    }
    
    // 动态计算：考勤完成度
    @Transient var attendanceCompletionRate: Double {
        guard attendanceBudget > 0 else { return 0 }
        return Double(totalActualMinutes) / attendanceBudget
    }
    
    // 动态计算：考勤评级 (A-F)
    @Transient var attendanceRating: String {
        let rate = attendanceCompletionRate
        switch rate {
        case 0.9...: return "A"
        case 0.75..<0.9: return "B"
        case 0.6..<0.75: return "C"
        case 0.4..<0.6: return "D"
        default: return "E/F"
        }
    }
}
//
//  RewardItem.swift
//  LifeMetrics
//
//  Created by centrix on 2026/2/21.
//


import SwiftData
import Foundation

@Model
class RewardItem {
    var id: UUID = UUID()
    var name: String // 如: 跑步强度
    var amount: Double // 完成量 (公里数或次数)
    var score: Double // 计算后的奖励分
    
    var weeklyPlan: WeeklyPlan?
    
    init(name: String, amount: Double, score: Double) {
        self.name = name
        self.amount = amount
        self.score = score
    }
}
//
//  TaskItem.swift
//  LifeMetrics
//
//  Created by centrix on 2026/2/21.
//


import SwiftData
import Foundation

@Model
class TaskItem {
    var id: UUID = UUID()
    var name: String // 工作类型，如：网络安全、法国史与法语
    var categoryRawValue: String 
    var plannedMinutes: Int 
    var actualMinutes: Int 
    
    var weeklyPlan: WeeklyPlan?
    
    init(name: String, category: TaskCategory, plannedMinutes: Int, actualMinutes: Int = 0) {
        self.name = name
        self.categoryRawValue = category.rawValue
        self.plannedMinutes = plannedMinutes
        self.actualMinutes = actualMinutes
    }
    
    @Transient var completionRate: Double {
        guard plannedMinutes > 0 else { return 0 }
        return Double(actualMinutes) / Double(plannedMinutes)
    }
    
    @Transient var calculatedWeight: Double {
        let category = TaskCategory(rawValue: categoryRawValue) ?? .reading
        return Double(actualMinutes) * category.weightMultiplier
    }
}
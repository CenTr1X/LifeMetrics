//
//  TaskCategory.swift
//  LifeMetrics
//
//  Created by centrix on 2026/2/21.
//


import Foundation
import SwiftUI

enum TaskCategory: String, Codable, CaseIterable {
    case professional = "专业学习"
    case extended = "拓展学习"    
    case reading = "阅读积累"
    
    // 核心权重系数公式
    var weightMultiplier: Double {
        switch self {
        case .professional: return 3.0
        case .extended: return 2.0
        case .reading: return 1.0
        }
    }
    
    // 为不同分类配置专属主题色 (用于图表和进度环)
    var themeColor: Color {
        switch self {
        case .professional: return .blue
        case .extended: return .orange
        case .reading: return .green
        }
    }
}
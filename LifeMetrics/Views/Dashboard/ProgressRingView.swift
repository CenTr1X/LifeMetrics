//
//  ProgressRingView.swift
//  LifeMetrics
//
//  Created by centrix on 2026/2/21.
//


import SwiftUI

struct ProgressRingView: View {
    var progress: Double // 进度 (0.0 - 1.0)
    var color: Color     // 环的颜色
    var lineWidth: CGFloat = 16 // 环的厚度
    
    var body: some View {
        ZStack {
            // 背景轨道环 (半透明)
            Circle()
                .stroke(color.opacity(0.2), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            // 进度环
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(Angle(degrees: -90)) // 从正上方 12 点钟方向开始绘制
                .animation(.easeInOut(duration: 1.0), value: progress) // 添加平滑加载动画
        }
    }
}
//
//  LevelCardView.swift
//  LifeMetrics
//
//  Created by centrix on 2026/2/21.
//


import SwiftUI

struct LevelCardView: View {
    let plan: WeeklyPlan
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("第 \(plan.weekNumber) 周战报")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("当前累计总分")
                        .font(.subheadline)
                    Text(String(format: "%.1f", plan.totalActualWeight))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                Spacer()
                
                // 考勤评级徽章
                VStack {
                    Text("考勤评级")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(plan.attendanceRating)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(ratingColor(for: plan.attendanceRating))
                        .padding()
                        .background(ratingColor(for: plan.attendanceRating).opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            Divider()
            
            // 进度条：考勤完成度预算
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("本周专注时长完成度")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(plan.attendanceCompletionRate * 100))%")
                        .font(.caption).bold()
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .frame(height: 10)
                            .foregroundColor(Color(UIColor.systemGray5))
                        Capsule()
                            .frame(width: min(CGFloat(plan.attendanceCompletionRate) * geometry.size.width, geometry.size.width), height: 10)
                            .foregroundColor(.indigo)
                    }
                }
                .frame(height: 10)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // 评级颜色逻辑
    private func ratingColor(for rating: String) -> Color {
        switch rating {
        case "A": return .green
        case "B": return .blue
        case "C": return .orange
        case "D": return .red
        default: return .gray
        }
    }
}
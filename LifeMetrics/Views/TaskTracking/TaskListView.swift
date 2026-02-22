import SwiftUI
import SwiftData
import Combine

struct TaskListView: View {
    @Query(sort: \WeeklyPlan.weekNumber, order: .reverse) private var plans: [WeeklyPlan]
    @State private var selectedTask: TaskItem?
    
    var body: some View {
        // 建议外层也同步升级为 NavigationStack
        NavigationStack {
            List {
                if let currentPlan = plans.first {
                    Section {
                        HStack {
                            Text("本周已专注")
                            Spacer()
                            Text("\(currentPlan.totalActualMinutes) / \(Int(currentPlan.attendanceBudget)) 分钟")
                                .bold()
                                .foregroundColor(.indigo)
                        }
                    }
                    
                    Section(header: Text("本周任务列表 (点击打卡/计时)")) {
                        ForEach(currentPlan.tasks) { task in
                            TaskRow(task: task)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTask = task
                                }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "暂无任务",
                        systemImage: "clipboard.text",
                        description: Text("请先在计划页创建本周计划，或在首页添加测试数据")
                    )
                }
            }
            .navigationTitle("执行打卡")
            .sheet(item: $selectedTask) { task in
                TaskActionSheet(task: task)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

// MARK: - 单个任务行
struct TaskRow: View {
    let task: TaskItem
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(TaskCategory(rawValue: task.categoryRawValue)?.themeColor ?? .gray)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(task.name).font(.headline)
                Text(task.categoryRawValue).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text("\(task.actualMinutes)/\(task.plannedMinutes)m")
                    .font(.subheadline).monospacedDigit()
                ProgressView(value: task.completionRate)
                    .progressViewStyle(.linear)
                    .tint(TaskCategory(rawValue: task.categoryRawValue)?.themeColor ?? .blue)
                    .frame(width: 70)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 打卡模式选择弹窗
struct TaskActionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: TaskItem
    
    // 0: 手动录入, 1: 番茄钟计时, 2: 正向计时
    @State private var selectedMode = 0
    
    var body: some View {
        // 修复1：改用 NavigationStack，解决部分旧版 NavigationView 的标题栏渲染 Bug
        NavigationStack {
            VStack(spacing: 0) {
                Picker("打卡模式", selection: $selectedMode) {
                    Text("手动补录").tag(0)
                    Text("番茄倒计").tag(1)
                    Text("正向计时").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 修复2：引入 ScrollView
                // 这样当 .medium 弹窗高度不够时，不会把上面的 Picker 顶出屏幕边界
                ScrollView {
                    VStack(spacing: 0) {
                        if selectedMode == 0 {
                            ManualRecordView(task: task) { addedMinutes in
                                saveRecord(minutes: addedMinutes)
                            }
                        } else if selectedMode == 1 {
                            FocusTimerView(task: task) { elapsedMinutes in
                                saveRecord(minutes: elapsedMinutes)
                            }
                        } else {
                            StopwatchTimerView(task: task) { elapsedMinutes in
                                saveRecord(minutes: elapsedMinutes)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.bottom, 30) // 底部留白，方便滚动
                }
            }
            .navigationTitle(task.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
    
    private func saveRecord(minutes: Int) {
        if minutes > 0 {
            task.actualMinutes += minutes
        }
        dismiss()
    }
}

// MARK: - 模式一：手动自定义时间补录
struct ManualRecordView: View {
    var task: TaskItem
    var onSave: (Int) -> Void
    
    @State private var customMinutes: String = "30"
    
    var body: some View {
        VStack(spacing: 30) {
            Text("手动记录：\(task.name)")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            VStack(spacing: 15) {
                Text("专注时长 (分钟)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("0", text: $customMinutes)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .foregroundColor(.indigo)
                    .padding(.vertical, 20)
                    .frame(width: 240)
                    .background(Color(UIColor.secondarySystemFill))
                    .cornerRadius(20)
            }
            .padding(.top, 10)
            
            Button(action: {
                if let mins = Int(customMinutes), mins > 0 {
                    onSave(mins)
                }
            }) {
                Text("提交打卡")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 240, height: 60)
                    .background(Color.indigo)
                    .cornerRadius(30)
            }
            .padding(.top, 20)
        }
        .padding(.top, 20)
    }
}

// MARK: - 模式二：番茄钟专注计时器 (倒计时)
struct FocusTimerView: View {
    var task: TaskItem
    var onSave: (Int) -> Void
    
    @State private var targetMinutes: Int = 25
    @State private var timeRemaining: Int = 25 * 60
    @State private var isRunning = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var progress: Double {
        let totalSeconds = targetMinutes * 60
        if totalSeconds == 0 { return 0 }
        return Double(totalSeconds - timeRemaining) / Double(totalSeconds)
    }
    
    var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            if !isRunning && timeRemaining == targetMinutes * 60 {
                Stepper("设定目标: \(targetMinutes) 分钟", value: $targetMinutes, in: 1...120, step: 5)
                    .onChange(of: targetMinutes) { _, newValue in
                        timeRemaining = newValue * 60
                    }
                    .padding(.horizontal, 40)
            } else {
                Text("倒计时：\(task.name)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
            }
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 15)
                    .opacity(0.2)
                    .foregroundColor(.indigo)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.indigo)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear(duration: 1.0), value: progress)
                
                Text(timeString)
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
            }
            .frame(width: 240, height: 240)
            .padding(.top, 10)
            
            HStack(spacing: 50) {
                Button(action: {
                    isRunning.toggle()
                }) {
                    Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(isRunning ? .orange : .indigo)
                }
                
                Button(action: {
                    isRunning = false
                    let elapsedSeconds = (targetMinutes * 60) - timeRemaining
                    let elapsedMinutes = elapsedSeconds / 60
                    onSave(elapsedMinutes)
                }) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.top, 20)
        .onReceive(timer) { _ in
            if isRunning && timeRemaining > 0 {
                timeRemaining -= 1
            } else if isRunning && timeRemaining == 0 {
                isRunning = false
                onSave(targetMinutes)
            }
        }
    }
}

// MARK: - 模式三：正向计时器
struct StopwatchTimerView: View {
    var task: TaskItem
    var onSave: (Int) -> Void
    
    @State private var elapsedSeconds: Int = 0
    @State private var isRunning = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var timeString: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
    
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("正在计时：\(task.name)")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 15)
                    .opacity(0.2)
                    .foregroundColor(.green)
                
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.green)
                    .opacity(isRunning && isPulsing ? 0.6 : 1.0)
                    .animation(isRunning ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: isPulsing)
                
                Text(timeString)
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
            }
            .frame(width: 240, height: 240)
            .padding(.top, 10)
            
            HStack(spacing: 50) {
                Button(action: {
                    isRunning.toggle()
                    if isRunning {
                        isPulsing = true
                    }
                }) {
                    Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(isRunning ? .orange : .green)
                }
                
                Button(action: {
                    isRunning = false
                    let mins = elapsedSeconds / 60
                    let finalMinutes = (elapsedSeconds > 0 && mins == 0) ? 1 : mins
                    onSave(finalMinutes)
                }) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.top, 20)
        .onReceive(timer) { _ in
            if isRunning {
                elapsedSeconds += 1
            }
        }
    }
}


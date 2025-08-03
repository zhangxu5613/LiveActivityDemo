import SwiftUI
import CoreData


typealias CallBack = () -> Void

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    private var callBack: CallBack? = nil
    
    
    private var timer: Timer?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var dispatchTimer: DispatchSourceTimer?
    
    func setTime(hours: Int, minutes: Int, seconds: Int) {
        totalTime = TimeInterval(hours * 3600 + minutes * 60 + seconds)
        timeRemaining = totalTime
    }
    func setCallBack(cb: @escaping CallBack) {
        callBack = cb
    }
    
    func startTimer() {
              
        // 开始后台任务
        beginBackgroundTask()
        
        // 创建 DispatchSourceTimer 用于更可靠的后台倒计时
        let queue = DispatchQueue.global(qos: .userInteractive)
        dispatchTimer = DispatchSource.makeTimerSource(queue: queue)
        dispatchTimer?.schedule(deadline: .now(), repeating: 1.0)
        dispatchTimer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.updateTimer()
            }
        }
        dispatchTimer?.resume()
        
        // 同时使用 Timer 用于 UI 更新
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//            self?.updateTimer()
//        }
//
//        // 将定时器添加到 RunLoop 中
//        RunLoop.main.add(timer!, forMode: .common)
    }
    func stopTimer() {
        dispatchTimer?.cancel()
        dispatchTimer = nil
        endBackgroundTask()
    }
    
    private func updateTimer() {
        print("time decr", timeRemaining)
        if timeRemaining > 0 {
            timeRemaining -= 1
            callBack!()
        } else {
            print("time is 0")
        }
    }
    
    private func beginBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "TimerBackgroundTask") { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    // 结束后台任务
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var paused = false
    @State private var num = 100
    @State private var showingNetworkSpeed = false
    @State private var showingWidget = false
    @State private var updateTimer: Timer?
    @StateObject private var timerManager = TimerManager()
    @StateObject private var networkMonitor = NetworkMonitor()

    var body: some View {
        // 网络速度显示区域
        if showingNetworkSpeed {
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: networkMonitor.isConnected ? "wifi" : "wifi.slash")
                        .foregroundColor(networkMonitor.isConnected ? .green : .red)
                    Text(networkMonitor.isConnected ? "已连接" : "未连接")
                        .foregroundColor(networkMonitor.isConnected ? .green : .red)
                }
                
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                        Text("下载速度:")
                        Spacer()
                        Text(networkMonitor.downloadSpeed)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("上传速度:")
                        Spacer()
                        Text(networkMonitor.uploadSpeed)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
        }
        
        // 按钮区域
        VStack(spacing: 15) {
            Button(action: {
                showingNetworkSpeed.toggle()
            }, label: {
                HStack {
                    Image(systemName: showingNetworkSpeed ? "eye.slash" : "eye")
                    Text(showingNetworkSpeed ? "隐藏网速" : "显示网速")
                }
                .frame(width: 200)
                .foregroundColor(.white)
            })
            .padding()
            .background(showingNetworkSpeed ? .orange : .blue)
            .cornerRadius(10)
            
            Button(action: {
                if (!showingWidget) {
                    startActivity()
                    timerManager.setTime(hours: 0, minutes: 1, seconds: 0)
                    timerManager.setCallBack(cb: updateActivity)
                    timerManager.startTimer()
                    showingWidget = true
                }else {
                    timerManager.stopTimer()
                    stopActivity()
                    showingWidget = false
                }
            }, label: {
                    Text(showingWidget ? "停止" : "开启").frame(width: 200).foregroundColor(.white)
            }).padding().background(showingWidget ? .red : .green).cornerRadius(10)
        }
    }

    func startActivity() {
        ActivityController.shared.startLiveActivity(attributes: .init(id: "ficow test"), initialState: .init(upload: networkMonitor.uploadSpeed, dwload: networkMonitor.downloadSpeed, endTime: .init(timeIntervalSinceNow: 10)), staleDate: nil, relevanceScore: 50)
//        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
//            updateActivity()
//        }
//        RunLoop.current.add(updateTimer!, forMode: .common)
        timerManager.setTime(hours: 0, minutes: 1, seconds: 0   )
        timerManager.setCallBack(cb: updateActivity)
        timerManager.startTimer()
    }

    func updateActivity()  {
        num = num - 1
        print("*******", num, networkMonitor.uploadSpeed, networkMonitor.downloadSpeed)
        Task { @MainActor in
            try await Task.sleep(for: .seconds(2))
            try await ActivityController.shared.updateActivity(state: .init(upload: networkMonitor.uploadSpeed, dwload: networkMonitor.downloadSpeed, pauseTime: paused ? .now : nil), staleDate: .init(timeIntervalSinceNow: 10), alert: .some((title: "alert title", body: "body")))
            paused.toggle()
        }
    }

    func stopActivity() {
        ActivityController.shared.endActivity(
            finalState: .init(upload: "End", dwload: "End"),
            dismissalPolicy: .immediate
        )
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}


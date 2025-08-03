//
//  NetworkMonitor.swift
//  NetStat
//
//  Created by 张徐 on 2025/8/2.
//

import Foundation
import Network
import SystemConfiguration

class NetworkMonitor: ObservableObject {
    @Published var downloadSpeed: String = "0 KB/s"
    @Published var uploadSpeed: String = "0 KB/s"
    @Published var isConnected: Bool = false
    
    private var lastDownloadBytes: UInt64 = 0
    private var lastUploadBytes: UInt64 = 0
    private var lastUpdateTime: Date = Date()
    private var timer: Timer?
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateNetworkSpeed()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateNetworkSpeed() {
        // 获取网络接口信息
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {
            return
        }
        defer { freeifaddrs(ifaddr) }
        
        var totalDownloadBytes: UInt64 = 0
        var totalUploadBytes: UInt64 = 0
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_LINK) {
                let name = String(cString: (interface?.ifa_name)!)
                if name == "en0" || name == "en1" { // WiFi接口
                    if let data = interface?.ifa_data {
                        let stats = data.assumingMemoryBound(to: if_data.self)
                        totalDownloadBytes += UInt64(stats.pointee.ifi_ibytes)
                        totalUploadBytes += UInt64(stats.pointee.ifi_obytes)
                    }
                }
            }
        }
        
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(lastUpdateTime)
        
        if timeInterval > 0 {
            let downloadDiff = totalDownloadBytes - lastDownloadBytes
            let uploadDiff = totalUploadBytes - lastUploadBytes
            
            let downloadSpeedBytes = Double(downloadDiff) / timeInterval
            let uploadSpeedBytes = Double(uploadDiff) / timeInterval
            
            if (lastDownloadBytes != 0) {
                downloadSpeed = formatSpeed(downloadSpeedBytes)
                uploadSpeed = formatSpeed(uploadSpeedBytes)
            }
            
            lastDownloadBytes = totalDownloadBytes
            lastUploadBytes = totalUploadBytes
            lastUpdateTime = currentTime
        }
        
        isConnected = checkInternetConnection()
    }
    
    private func formatSpeed(_ bytesPerSecond: Double) -> String {
        if bytesPerSecond >= 1024 * 1024 {
            return String(format: "%.1f MB/s", bytesPerSecond / (1024 * 1024))
        } else if bytesPerSecond >= 1024 {
            return String(format: "%.1f KB/s", bytesPerSecond / 1024)
        } else {
            return String(format: "%.0f B/s", bytesPerSecond)
        }
    }
    
    private func checkInternetConnection() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
    deinit {
        stopMonitoring()
    }
} 

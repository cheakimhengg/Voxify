import Foundation

public enum LogLevel: String {
    case debug
    case info
    case warn
    case error
}

public struct Logger {
    public static func log(_ message: String, level: LogLevel = .info, subsystem: String = "Voxify") {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("[\(timestamp)] [\(subsystem)] [\(level.rawValue.uppercased())] \(message)")
    }
}

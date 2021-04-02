import Foundation

/// A very simple logger.
struct Logger {
    enum Level: Int, CustomStringConvertible, Hashable, Comparable {
        case error = 3
        case warn = 2
        case info = 1
        case debug = 0
        case trace = -1
        
        var description: String {
            switch self {
            case .error: return "error"
            case .warn: return "warn"
            case .info: return "info"
            case .debug: return "debug"
            case .trace: return "trace"
            }
        }
        
        static func <(lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    var name: String
    var level: Level = .info
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()
    
    func log(at level: Level, message: @autoclosure () -> String) {
        if level >= self.level {
            print("[\(level)] \(formatter.string(from: Date())) \(message())")
        }
    }
    
    func error(_ message: @autoclosure () -> String) { log(at: .error, message: message()) }
    
    func warn(_ message: @autoclosure () -> String) { log(at: .warn, message: message()) }
    
    func info(_ message: @autoclosure () -> String) { log(at: .info, message: message()) }
    
    func debug(_ message: @autoclosure () -> String) { log(at: .debug, message: message()) }
    
    func trace(_ message: @autoclosure () -> String) { log(at: .trace, message: message()) }
}

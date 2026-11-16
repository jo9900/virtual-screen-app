import Foundation

/// Writes timestamped lines to stderr, which the LaunchAgent sends to its log file.
enum Log {
    static func info(_ message: String) {
        write("INFO", message)
    }

    static func error(_ message: String) {
        write("ERROR", message)
    }

    private static func write(_ level: String, _ message: String) {
        let line = "\(Date.now.ISO8601Format()) \(level) \(message)\n"
        FileHandle.standardError.write(Data(line.utf8))
    }
}

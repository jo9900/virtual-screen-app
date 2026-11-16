import Foundation

public struct Resolution: Hashable, Sendable, CustomStringConvertible {
    public let width: Int
    public let height: Int

    public static let presets: [Resolution] = [
        Resolution(width: 1920, height: 1080),
        Resolution(width: 2560, height: 1440),
        Resolution(width: 3200, height: 1800),
        Resolution(width: 3840, height: 2160),
    ]

    public static let defaultResolution = Resolution(width: 2560, height: 1440)

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    /// Accepts `WIDTHxHEIGHT`, case-insensitive, with `x` or `×` as the separator.
    public init?(parsing text: String) {
        let normalized = text
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
            .replacingOccurrences(of: "×", with: "x")
        let parts = normalized.split(separator: "x", omittingEmptySubsequences: false)
        guard parts.count == 2,
              let width = Int(parts[0]), width > 0,
              let height = Int(parts[1]), height > 0
        else { return nil }
        self.init(width: width, height: height)
    }

    public var description: String { "\(width)x\(height)" }

    public func scaled(by factor: Int) -> Resolution {
        Resolution(width: width * factor, height: height * factor)
    }
}

/// A preset resolution plus whether it renders at 2x (HiDPI) or 1x.
public struct DisplaySelection: Hashable, Sendable {
    public let resolution: Resolution
    public let hiDPI: Bool

    public static let defaultSelection = DisplaySelection(resolution: .defaultResolution, hiDPI: true)

    public init(resolution: Resolution, hiDPI: Bool) {
        self.resolution = resolution
        self.hiDPI = hiDPI
    }

    /// Matches a display mode (size in points and in pixels) against the presets.
    public init?(points: Resolution, pixels: Resolution) {
        guard Resolution.presets.contains(points) else { return nil }
        switch pixels {
        case points.scaled(by: 2): self.init(resolution: points, hiDPI: true)
        case points: self.init(resolution: points, hiDPI: false)
        default: return nil
        }
    }

    /// Restores a saved selection; unknown or non-preset text falls back to the default resolution.
    public init(storedResolution: String?, hiDPI: Bool) {
        let parsed = storedResolution.flatMap(Resolution.init(parsing:))
        guard let parsed, Resolution.presets.contains(parsed) else {
            self.init(resolution: .defaultResolution, hiDPI: hiDPI)
            return
        }
        self.init(resolution: parsed, hiDPI: hiDPI)
    }

    public var storedResolution: String {
        resolution.description
    }

    public var plan: ModePlan {
        ModePlan(resolution: resolution, hiDPI: hiDPI)
    }
}

/// The pixel modes registered on the virtual display and the one to activate.
///
/// `CGVirtualDisplayMode` sizes are in pixels. With HiDPI enabled, macOS also
/// offers each pixel mode at half its size in points, so registering every
/// preset at 2x and 1x makes all of them selectable in both forms.
public struct ModePlan: Equatable, Sendable, CustomStringConvertible {
    public let resolution: Resolution
    public let hiDPI: Bool
    public let targetPixels: Resolution
    /// Target mode first: macOS starts the display in the first mode listed.
    public let pixelModes: [Resolution]
    public let maxPixels: Resolution

    public init(resolution: Resolution, hiDPI: Bool, presets: [Resolution] = Resolution.presets) {
        let target = resolution.scaled(by: hiDPI ? 2 : 1)
        let candidates = (presets.map { $0.scaled(by: 2) } + presets).sorted { $0.width > $1.width }
        var seen: Set<Resolution> = [target]
        var modes = [target]
        for mode in candidates where seen.insert(mode).inserted {
            modes.append(mode)
        }

        self.resolution = resolution
        self.hiDPI = hiDPI
        self.targetPixels = target
        self.pixelModes = modes
        self.maxPixels = Resolution(
            width: modes.map(\.width).max() ?? target.width,
            height: modes.map(\.height).max() ?? target.height
        )
    }

    public var description: String {
        "\(resolution) \(hiDPI ? "HiDPI" : "1x") (\(targetPixels) px)"
    }
}

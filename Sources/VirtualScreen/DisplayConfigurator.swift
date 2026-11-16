import CoreGraphics
import VirtualScreenCore

enum DisplayConfigurationError: Error, CustomStringConvertible {
    case modeNotFound(ModePlan)
    case configurationFailed(CGError)

    var description: String {
        switch self {
        case .modeNotFound(let plan): "display mode \(plan) is not available"
        case .configurationFailed(let error): "display configuration failed with CGError \(error.rawValue)"
        }
    }
}

enum DisplayConfigurator {
    static func waitUntilOnline(_ id: CGDirectDisplayID, timeout: Duration) -> Bool {
        let deadline = ContinuousClock.now + timeout
        while !onlineDisplays().contains(id) {
            guard ContinuousClock.now < deadline else { return false }
            // Runs the main run loop so the display's dispatch queue keeps working while we wait.
            CFRunLoopRunInMode(.defaultMode, 0.1, false)
        }
        return true
    }

    static func activateMode(on id: CGDirectDisplayID, plan: ModePlan) throws(DisplayConfigurationError) {
        if let current = CGDisplayCopyDisplayMode(id), matches(current, plan) { return }

        let options = [kCGDisplayShowDuplicateLowResolutionModes: true] as CFDictionary
        let modes = CGDisplayCopyAllDisplayModes(id, options) as? [CGDisplayMode] ?? []
        let candidates = modes.filter { matches($0, plan) }
        guard let mode = candidates.first(where: { $0.isUsableForDesktopGUI() }) ?? candidates.first else {
            throw .modeNotFound(plan)
        }
        try configure { CGConfigureDisplayWithDisplayMode($0, id, mode, nil) }
    }

    /// The main display is the one at the global origin, so shift every display
    /// by the virtual display's offset to keep the arrangement intact.
    static func makeMain(_ id: CGDirectDisplayID) throws(DisplayConfigurationError) {
        let offset = CGDisplayBounds(id).origin
        guard offset != .zero else { return }

        let displays = activeDisplays().filter { CGDisplayMirrorsDisplay($0) == kCGNullDirectDisplay }
        try configure { config in
            for display in displays {
                let origin = CGDisplayBounds(display).origin
                CGConfigureDisplayOrigin(config, display, Int32(origin.x - offset.x), Int32(origin.y - offset.y))
            }
        }
    }

    static func currentModeDescription(_ id: CGDirectDisplayID) -> String {
        guard let mode = CGDisplayCopyDisplayMode(id) else { return "unknown mode" }
        return "\(mode.width)x\(mode.height) (\(mode.pixelWidth)x\(mode.pixelHeight) px)"
    }

    private static func matches(_ mode: CGDisplayMode, _ plan: ModePlan) -> Bool {
        mode.width == plan.resolution.width
            && mode.height == plan.resolution.height
            && mode.pixelWidth == plan.targetPixels.width
            && mode.pixelHeight == plan.targetPixels.height
    }

    private static func configure(_ changes: (CGDisplayConfigRef?) -> Void) throws(DisplayConfigurationError) {
        var config: CGDisplayConfigRef?
        let beginError = CGBeginDisplayConfiguration(&config)
        guard beginError == .success else { throw .configurationFailed(beginError) }
        changes(config)
        let completeError = CGCompleteDisplayConfiguration(config, .forSession)
        guard completeError == .success else { throw .configurationFailed(completeError) }
    }

    private static func onlineDisplays() -> [CGDirectDisplayID] {
        displayList(CGGetOnlineDisplayList)
    }

    private static func activeDisplays() -> [CGDirectDisplayID] {
        displayList(CGGetActiveDisplayList)
    }

    private static func displayList(
        _ query: (UInt32, UnsafeMutablePointer<CGDirectDisplayID>?, UnsafeMutablePointer<UInt32>?) -> CGError
    ) -> [CGDirectDisplayID] {
        var count: UInt32 = 0
        guard query(0, nil, &count) == .success, count > 0 else { return [] }
        var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
        guard query(count, &ids, &count) == .success else { return [] }
        return Array(ids.prefix(Int(count)))
    }
}

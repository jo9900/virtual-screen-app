import CoreGraphics
import VirtualScreenCore

/// User-facing text for the display state.
@MainActor
enum StatusText {
    static func describe(_ status: DisplayController.Status) -> String {
        switch status {
        case .off:
            String(localized: "Virtual Screen Is Off")
        case .starting:
            String(localized: "Starting Virtual Screen…")
        case .failed:
            String(localized: "Could Not Create Virtual Screen")
        case .on(let id):
            describeRunning(id)
        }
    }

    static func size(_ resolution: Resolution) -> String {
        "\(resolution.width) × \(resolution.height)"
    }

    private static func describeRunning(_ id: CGDirectDisplayID) -> String {
        guard let mode = DisplayConfigurator.currentMode(of: id) else {
            return String(localized: "Starting Virtual Screen…")
        }
        let isHiDPI = mode.pixels.width > mode.points.width
        let modeText = isHiDPI ? "\(size(mode.points)) HiDPI" : size(mode.points)
        return DisplayConfigurator.isMain(id) ? String(localized: "\(modeText) · Main Display") : modeText
    }
}

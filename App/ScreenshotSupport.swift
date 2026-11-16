import Foundation

/// Debug-only hook for capturing App Store screenshots: launch with `-ScreenshotMenu YES`
/// to skip the login prompt and open the menu once the display is up.
@MainActor
enum ScreenshotSupport {
    private static let openDelay: Duration = .seconds(3)

    static var isActive: Bool {
        #if DEBUG
        UserDefaults.standard.bool(forKey: "ScreenshotMenu")
        #else
        false
        #endif
    }

    static func openMenuWhenReady(_ menu: StatusMenu) {
        Task {
            try? await Task.sleep(for: openDelay)
            menu.open()
        }
    }
}

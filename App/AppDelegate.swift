import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = AppSettings()
    private let loginItem = LoginItem()
    private lazy var controller = DisplayController(settings: settings)
    private var statusMenu: StatusMenu?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let menu = StatusMenu(controller: controller, loginItem: loginItem)
        statusMenu = menu
        controller.onChange = { [weak menu] in menu?.refresh() }

        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.controller.syncWithSystem() }
        }

        controller.startIfEnabled()

        if ScreenshotSupport.isActive {
            ScreenshotSupport.openMenuWhenReady(menu)
        } else {
            LoginItemPrompt.askIfNeeded(settings: settings, loginItem: loginItem)
        }
    }
}

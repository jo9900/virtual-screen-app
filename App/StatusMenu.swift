import AppKit
import VirtualScreenCore

/// The menu bar item and its menu. The menu is rebuilt whenever it opens or the state changes.
@MainActor
final class StatusMenu: NSObject, NSMenuDelegate {
    private static let displaysSettingsURL = URL(string: "x-apple.systempreferences:com.apple.Displays-Settings.extension")

    private let controller: DisplayController
    private let loginItem: LoginItem
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()

    init(controller: DisplayController, loginItem: LoginItem) {
        self.controller = controller
        self.loginItem = loginItem
        super.init()

        menu.delegate = self
        statusItem.menu = menu
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "display", accessibilityDescription: "Virtual Screen")
            button.image?.isTemplate = true
        }
        rebuild()
    }

    func refresh() {
        rebuild()
    }

    /// Opens the menu as if clicked. Used to capture App Store screenshots.
    func open() {
        statusItem.button?.performClick(nil)
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        rebuild()
    }

    private func rebuild() {
        statusItem.button?.appearsDisabled = controller.status == .off
        menu.removeAllItems()

        menu.addItem(disabledItem(StatusText.describe(controller.status)))
        if controller.status == .failed {
            menu.addItem(item(String(localized: "Try Again"), action: #selector(retry)))
        }
        menu.addItem(.separator())

        menu.addItem(item(String(localized: "Enable Virtual Screen"), action: #selector(toggleEnabled), checked: controller.isActive))
        menu.addItem(.separator())

        menu.addItem(.sectionHeader(title: String(localized: "Resolution")))
        let selection = controller.selection
        for resolution in Resolution.presets {
            let resolutionItem = item(StatusText.size(resolution), action: #selector(selectResolution(_:)), checked: resolution == selection.resolution)
            resolutionItem.representedObject = resolution.description
            menu.addItem(resolutionItem)
        }
        menu.addItem(item(String(localized: "HiDPI (Retina)"), action: #selector(toggleHiDPI), checked: selection.hiDPI))
        menu.addItem(.separator())

        menu.addItem(item(String(localized: "Displays Settings…"), action: #selector(openDisplaysSettings)))
        menu.addItem(loginMenuItem())
        menu.addItem(.separator())

        menu.addItem(item(String(localized: "About Virtual Screen"), action: #selector(showAbout)))
        menu.addItem(item(String(localized: "Quit Virtual Screen"), action: #selector(quit), keyEquivalent: "q"))
    }

    private func loginMenuItem() -> NSMenuItem {
        if loginItem.needsApproval {
            return item(String(localized: "Start at Login (Needs Approval)"), action: #selector(openLoginItemsSettings))
        }
        return item(String(localized: "Start at Login"), action: #selector(toggleLoginItem), checked: loginItem.isEnabled)
    }

    private func item(_ title: String, action: Selector, checked: Bool = false, keyEquivalent: String = "") -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        menuItem.target = self
        menuItem.state = checked ? .on : .off
        return menuItem
    }

    private func disabledItem(_ title: String) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.isEnabled = false
        return menuItem
    }

    @objc private func retry() {
        controller.retry()
    }

    @objc private func toggleEnabled() {
        controller.setEnabled(!controller.isActive)
    }

    @objc private func selectResolution(_ sender: NSMenuItem) {
        guard let text = sender.representedObject as? String, let resolution = Resolution(parsing: text) else { return }
        controller.select(DisplaySelection(resolution: resolution, hiDPI: controller.selection.hiDPI))
    }

    @objc private func toggleHiDPI() {
        let selection = controller.selection
        controller.select(DisplaySelection(resolution: selection.resolution, hiDPI: !selection.hiDPI))
    }

    @objc private func openDisplaysSettings() {
        guard let url = Self.displaysSettingsURL else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func toggleLoginItem() {
        loginItem.setEnabled(!loginItem.isEnabled)
        rebuild()
    }

    @objc private func openLoginItemsSettings() {
        loginItem.openSystemSettings()
    }

    @objc private func showAbout() {
        NSApp.activate()
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

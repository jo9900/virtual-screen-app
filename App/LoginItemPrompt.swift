import AppKit

/// Asks once whether to start at login; apps must not add a login item without consent.
@MainActor
enum LoginItemPrompt {
    static func askIfNeeded(settings: AppSettings, loginItem: LoginItem) {
        guard !settings.didAskAboutLoginItem, !loginItem.isRegistered else { return }
        settings.didAskAboutLoginItem = true

        let alert = NSAlert()
        alert.messageText = String(localized: "Start Virtual Screen at login?")
        alert.informativeText = String(localized: """
            Virtual Screen runs in the menu bar. Starting it at login brings the virtual screen back \
            after every restart, which a Mac without a monitor needs for remote access.
            """)
        alert.addButton(withTitle: String(localized: "Start at Login"))
        alert.addButton(withTitle: String(localized: "Not Now"))

        NSApp.activate()
        if alert.runModal() == .alertFirstButtonReturn {
            loginItem.setEnabled(true)
        }
    }
}

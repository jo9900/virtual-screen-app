import OSLog
import ServiceManagement

/// Starts the app at login through the system's Login Items.
@MainActor
struct LoginItem {
    private let logger = Logger(subsystem: "io.github.jo9900.VirtualScreen", category: "login-item")

    var isEnabled: Bool { SMAppService.mainApp.status == .enabled }
    var needsApproval: Bool { SMAppService.mainApp.status == .requiresApproval }
    // An app that never registered can report `.notFound` as well as `.notRegistered`.
    var isRegistered: Bool { isEnabled || needsApproval }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            logger.error("Updating the login item failed: \(error.localizedDescription, privacy: .public)")
        }
        if needsApproval { openSystemSettings() }
    }

    func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}

import CoreGraphics
import Foundation
import OSLog
import VirtualScreenCore

/// Owns the virtual display and keeps it in line with `AppSettings`.
@MainActor
final class DisplayController {
    enum Status: Equatable {
        case off
        case starting
        case on(CGDirectDisplayID)
        case failed
    }

    private static let onlineTimeout: Duration = .seconds(5)
    private static let recreateDelay: Duration = .seconds(3)

    private let settings: AppSettings
    private let logger = Logger(subsystem: "io.github.jo9900.VirtualScreen", category: "display")
    private var display: VirtualDisplay?
    // Bumped whenever the display is released, so late callbacks from an old display are ignored.
    private var generation = 0
    private var recreateTask: Task<Void, Never>?

    private(set) var status: Status = .off {
        didSet { onChange?() }
    }

    var onChange: (() -> Void)?

    /// Follows the actual state rather than the saved flag, which can be edited outside the app.
    var isActive: Bool { status != .off }
    var selection: DisplaySelection { settings.selection }

    init(settings: AppSettings) {
        self.settings = settings
    }

    func startIfEnabled() {
        if settings.isEnabled { start() }
    }

    func setEnabled(_ enabled: Bool) {
        settings.isEnabled = enabled
        if enabled { start() } else { stop() }
    }

    func retry() {
        start()
    }

    /// Switches the running display in place; every preset is registered, so no restart is needed.
    func select(_ selection: DisplaySelection) {
        settings.selection = selection
        guard case .on(let id) = status else {
            onChange?()
            return
        }
        do {
            try DisplayConfigurator.activateMode(on: id, plan: selection.plan)
        } catch {
            logger.error("Switching mode failed: \(error.description, privacy: .public)")
        }
        onChange?()
    }

    /// Adopts a preset mode chosen elsewhere (e.g. System Settings) as the saved selection.
    func syncWithSystem() {
        defer { onChange?() }
        guard case .on(let id) = status,
              let mode = DisplayConfigurator.currentMode(of: id),
              let current = DisplaySelection(points: mode.points, pixels: mode.pixels),
              current != settings.selection
        else { return }
        settings.selection = current
    }

    private func start() {
        release()
        let startGeneration = generation
        status = .starting

        let plan = settings.selection.plan
        let newDisplay: VirtualDisplay
        do {
            newDisplay = try VirtualDisplay(plan: plan) { [weak self] in
                MainActor.assumeIsolated { self?.displayWasTerminated(generation: startGeneration) }
            }
        } catch {
            logger.error("Creating the display failed: \(error.description, privacy: .public)")
            status = .failed
            return
        }
        display = newDisplay

        let id = newDisplay.id
        Task {
            let online = await DisplayConfigurator.waitUntilOnline(id, timeout: Self.onlineTimeout)
            guard startGeneration == generation else { return }
            guard online else {
                logger.error("Display \(id) did not come online")
                release()
                status = .failed
                return
            }
            configure(id, plan: plan)
            status = .on(id)
        }
    }

    private func configure(_ id: CGDirectDisplayID, plan: ModePlan) {
        do {
            try DisplayConfigurator.activateMode(on: id, plan: plan)
            try DisplayConfigurator.makeMain(id)
        } catch {
            // The display still works in whatever mode and position macOS chose.
            logger.error("Configuring display \(id) failed: \(error.description, privacy: .public)")
        }
    }

    private func stop() {
        release()
        status = .off
    }

    private func release() {
        recreateTask?.cancel()
        recreateTask = nil
        generation += 1
        display = nil
    }

    private func displayWasTerminated(generation terminatedGeneration: Int) {
        guard terminatedGeneration == generation else { return }
        logger.error("The system removed the virtual display; recreating it")
        release()
        status = .starting
        recreateTask = Task {
            try? await Task.sleep(for: Self.recreateDelay)
            guard !Task.isCancelled, settings.isEnabled else { return }
            start()
        }
    }
}

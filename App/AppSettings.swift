import Foundation
import VirtualScreenCore

/// Persists the user's choices. The keys are also the SSH recovery interface documented in
/// the README (`defaults write ... isEnabled -bool false`), so keep them stable.
@MainActor
final class AppSettings {
    private enum Key {
        static let isEnabled = "isEnabled"
        static let resolution = "resolution"
        static let hiDPI = "hiDPI"
        static let didAskAboutLoginItem = "didAskAboutLoginItem"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.isEnabled: true,
            Key.resolution: DisplaySelection.defaultSelection.storedResolution,
            Key.hiDPI: DisplaySelection.defaultSelection.hiDPI,
        ])
    }

    var isEnabled: Bool {
        get { defaults.bool(forKey: Key.isEnabled) }
        set { defaults.set(newValue, forKey: Key.isEnabled) }
    }

    var selection: DisplaySelection {
        get {
            DisplaySelection(
                storedResolution: defaults.string(forKey: Key.resolution),
                hiDPI: defaults.bool(forKey: Key.hiDPI)
            )
        }
        set {
            defaults.set(newValue.storedResolution, forKey: Key.resolution)
            defaults.set(newValue.hiDPI, forKey: Key.hiDPI)
        }
    }

    var didAskAboutLoginItem: Bool {
        get { defaults.bool(forKey: Key.didAskAboutLoginItem) }
        set { defaults.set(newValue, forKey: Key.didAskAboutLoginItem) }
    }
}

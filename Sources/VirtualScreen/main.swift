import CoreGraphics
import Foundation
import VirtualScreenCore

let options: Options
do {
    options = try Options.parse(Array(CommandLine.arguments.dropFirst()))
} catch {
    FileHandle.standardError.write(Data("error: \(error)\n\n\(Options.usage)\n".utf8))
    exit(EX_USAGE)
}

let plan = ModePlan(resolution: options.resolution, hiDPI: options.hiDPI)

switch options.command {
case .help:
    print(Options.usage)
    exit(EXIT_SUCCESS)
case .list:
    Resolution.presets.forEach { print($0) }
    exit(EXIT_SUCCESS)
case .dryRun:
    print(plan)
    exit(EXIT_SUCCESS)
case .run:
    break
}

Log.info("Creating virtual display: \(plan)")

let virtualDisplay: VirtualDisplay
do {
    virtualDisplay = try VirtualDisplay(plan: plan) {
        // A non-zero exit makes launchd restart us and recreate the display.
        Log.error("The system terminated the virtual display; exiting")
        exit(EXIT_FAILURE)
    }
} catch {
    Log.error("\(error)")
    exit(EXIT_FAILURE)
}

let displayID = virtualDisplay.id
guard DisplayConfigurator.waitUntilOnline(displayID, timeout: .seconds(5)) else {
    Log.error("Display \(displayID) did not come online")
    exit(EXIT_FAILURE)
}

// Mode and arrangement failures are logged but not fatal: the display is still usable.
do {
    try DisplayConfigurator.activateMode(on: displayID, plan: plan)
} catch {
    Log.error("\(error)")
}
do {
    try DisplayConfigurator.makeMain(displayID)
} catch {
    Log.error("\(error)")
}

Log.info(
    "Display \(displayID) ready: \(DisplayConfigurator.currentModeDescription(displayID)), "
        + "main=\(CGDisplayIsMain(displayID) != 0)"
)

let signalSources = TerminationSignals.install()
withExtendedLifetime((virtualDisplay, signalSources)) {
    CFRunLoopRun()
}

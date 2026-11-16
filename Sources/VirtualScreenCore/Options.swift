public enum OptionsError: Error, Equatable, CustomStringConvertible {
    case missingValue(String)
    case invalidResolution(String)
    case unsupportedResolution(String)
    case unknownArgument(String)

    public var description: String {
        switch self {
        case .missingValue(let option):
            "\(option) requires a value"
        case .invalidResolution(let value):
            "'\(value)' is not a resolution; expected WIDTHxHEIGHT"
        case .unsupportedResolution(let value):
            "\(value) is not supported; choose one of: \(Resolution.presets.map(\.description).joined(separator: ", "))"
        case .unknownArgument(let argument):
            "unknown argument '\(argument)'"
        }
    }
}

public struct Options: Equatable, Sendable {
    public enum Command: Equatable, Sendable {
        case run
        case list
        case dryRun
        case help
    }

    public var command: Command = .run
    public var resolution: Resolution = .defaultResolution
    public var hiDPI = true

    public static let usage = """
        Usage: virtual-screen [--resolution WIDTHxHEIGHT] [--no-hidpi]
               virtual-screen --list | --dry-run | --help

        Creates a virtual display, makes it the main display, and keeps it
        alive until the process exits.

        Options:
          --resolution WxH  Resolution in points (default \(Resolution.defaultResolution)). See --list.
          --no-hidpi        Start in the 1x mode instead of HiDPI (2x pixels).
          --list            Print the supported resolutions.
          --dry-run         Validate the options, print the mode to use, and exit.
          -h, --help        Show this help.
        """

    public static func parse(_ arguments: [String]) throws(OptionsError) -> Options {
        var options = Options()
        var remaining = arguments[...]
        while let argument = remaining.popFirst() {
            switch argument {
            case "--list":
                options.command = .list
            case "--dry-run":
                options.command = .dryRun
            case "--help", "-h":
                options.command = .help
            case "--no-hidpi":
                options.hiDPI = false
            case "--resolution":
                guard let value = remaining.popFirst() else { throw .missingValue(argument) }
                options.resolution = try parseResolution(value)
            case _ where argument.hasPrefix("--resolution="):
                options.resolution = try parseResolution(String(argument.dropFirst("--resolution=".count)))
            default:
                throw .unknownArgument(argument)
            }
        }
        return options
    }

    private static func parseResolution(_ value: String) throws(OptionsError) -> Resolution {
        guard let resolution = Resolution(parsing: value) else { throw .invalidResolution(value) }
        guard Resolution.presets.contains(resolution) else { throw .unsupportedResolution(value) }
        return resolution
    }
}

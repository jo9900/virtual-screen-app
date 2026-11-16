import Testing
@testable import VirtualScreenCore

struct OptionsTests {
    @Test func defaultsToHiDPIAtDefaultResolution() throws {
        let options = try Options.parse([])
        #expect(options == Options(command: .run, resolution: .defaultResolution, hiDPI: true))
    }

    @Test func parsesResolutionAndNoHiDPI() throws {
        let options = try Options.parse(["--resolution", "3840x2160", "--no-hidpi"])
        #expect(options == Options(command: .run, resolution: Resolution(width: 3840, height: 2160), hiDPI: false))
    }

    @Test func parsesInlineResolutionValue() throws {
        let options = try Options.parse(["--resolution=1920x1080"])
        #expect(options.resolution == Resolution(width: 1920, height: 1080))
    }

    @Test(arguments: [
        (["--list"], Options.Command.list),
        (["--help"], .help),
        (["-h"], .help),
        (["--dry-run"], .dryRun),
    ])
    func parsesCommands(_ arguments: [String], _ command: Options.Command) throws {
        #expect(try Options.parse(arguments).command == command)
    }

    @Test func rejectsMissingResolutionValue() {
        #expect(throws: OptionsError.missingValue("--resolution")) {
            try Options.parse(["--resolution"])
        }
    }

    @Test func rejectsNonPresetResolution() {
        #expect(throws: OptionsError.unsupportedResolution("1366x768")) {
            try Options.parse(["--resolution", "1366x768"])
        }
    }

    @Test func rejectsUnknownArgument() {
        #expect(throws: OptionsError.unknownArgument("--main")) {
            try Options.parse(["--main"])
        }
    }
}

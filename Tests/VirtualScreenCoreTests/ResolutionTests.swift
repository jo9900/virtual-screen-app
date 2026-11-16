import Testing
@testable import VirtualScreenCore

struct ResolutionTests {
    @Test(arguments: ["2560x1440", "2560X1440", "2560×1440", " 2560x1440 "])
    func parsesPresetText(_ text: String) {
        #expect(Resolution(parsing: text) == Resolution(width: 2560, height: 1440))
    }

    @Test(arguments: ["", "2560", "2560x", "x1440", "abcxdef", "-1x1440", "2560x1440x1"])
    func rejectsMalformedText(_ text: String) {
        #expect(Resolution(parsing: text) == nil)
    }

    @Test func describesAsWidthByHeight() {
        #expect(Resolution(width: 3840, height: 2160).description == "3840x2160")
    }

    @Test func scalesBothDimensions() {
        #expect(Resolution(width: 1920, height: 1080).scaled(by: 2) == Resolution(width: 3840, height: 2160))
    }

    @Test func defaultIsAPreset() {
        #expect(Resolution.presets.contains(Resolution.defaultResolution))
        #expect(Resolution.defaultResolution == Resolution(width: 2560, height: 1440))
    }

    @Test func presetsAreSixteenByNine() {
        for preset in Resolution.presets {
            #expect(preset.width * 9 == preset.height * 16)
        }
    }
}

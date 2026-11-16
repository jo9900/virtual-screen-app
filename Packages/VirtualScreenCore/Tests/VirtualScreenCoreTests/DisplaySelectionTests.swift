import Testing
@testable import VirtualScreenCore

struct DisplaySelectionTests {
    @Test func defaultIsHiDPIAtDefaultResolution() {
        #expect(DisplaySelection.defaultSelection == DisplaySelection(resolution: .defaultResolution, hiDPI: true))
    }

    @Test func recognizesAHiDPIPresetMode() {
        let selection = DisplaySelection(
            points: Resolution(width: 2560, height: 1440),
            pixels: Resolution(width: 5120, height: 2880)
        )
        #expect(selection == DisplaySelection(resolution: Resolution(width: 2560, height: 1440), hiDPI: true))
    }

    @Test func recognizesA1xPresetMode() {
        let selection = DisplaySelection(
            points: Resolution(width: 3840, height: 2160),
            pixels: Resolution(width: 3840, height: 2160)
        )
        #expect(selection == DisplaySelection(resolution: Resolution(width: 3840, height: 2160), hiDPI: false))
    }

    @Test func ignoresModesOutsideThePresets() {
        // macOS adds extra modes such as 1280x720 HiDPI that the menu does not offer.
        #expect(DisplaySelection(points: Resolution(width: 1280, height: 720), pixels: Resolution(width: 2560, height: 1440)) == nil)
    }

    @Test func ignoresScalesOtherThanOneAndTwo() {
        #expect(DisplaySelection(points: Resolution(width: 1920, height: 1080), pixels: Resolution(width: 5760, height: 3240)) == nil)
    }

    @Test func restoresAStoredPreset() {
        let selection = DisplaySelection(storedResolution: "3840x2160", hiDPI: false)
        #expect(selection == DisplaySelection(resolution: Resolution(width: 3840, height: 2160), hiDPI: false))
    }

    @Test(arguments: [nil, "", "garbage", "1366x768"])
    func fallsBackToTheDefaultResolutionForUnusableStoredValues(_ stored: String?) {
        let selection = DisplaySelection(storedResolution: stored, hiDPI: true)
        #expect(selection == DisplaySelection(resolution: .defaultResolution, hiDPI: true))
    }

    @Test func storesTheResolutionAsText() {
        #expect(DisplaySelection.defaultSelection.storedResolution == "2560x1440")
    }

    @Test func buildsThePlanForItsResolutionAndScale() {
        let plan = DisplaySelection(resolution: Resolution(width: 1920, height: 1080), hiDPI: true).plan
        #expect(plan.targetPixels == Resolution(width: 3840, height: 2160))
    }
}

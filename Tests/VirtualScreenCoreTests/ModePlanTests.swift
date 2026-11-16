import Testing
@testable import VirtualScreenCore

struct ModePlanTests {
    @Test func hiDPIUsesDoublePixelsForTheTargetMode() {
        let plan = ModePlan(resolution: Resolution(width: 2560, height: 1440), hiDPI: true)
        #expect(plan.targetPixels == Resolution(width: 5120, height: 2880))
        #expect(plan.pixelModes.first == plan.targetPixels)
    }

    @Test func nonHiDPIUsesNativePixelsForTheTargetMode() {
        let plan = ModePlan(resolution: Resolution(width: 2560, height: 1440), hiDPI: false)
        #expect(plan.targetPixels == Resolution(width: 2560, height: 1440))
        #expect(plan.pixelModes.first == plan.targetPixels)
    }

    @Test func registersEveryPresetAtBothScales() {
        let plan = ModePlan(resolution: .defaultResolution, hiDPI: true)
        for preset in Resolution.presets {
            #expect(plan.pixelModes.contains(preset))
            #expect(plan.pixelModes.contains(preset.scaled(by: 2)))
        }
    }

    @Test func listsEachPixelModeOnce() {
        let plan = ModePlan(resolution: Resolution(width: 1920, height: 1080), hiDPI: true)
        #expect(Set(plan.pixelModes).count == plan.pixelModes.count)
    }

    @Test func describesResolutionScaleAndPixels() {
        #expect(ModePlan(resolution: .defaultResolution, hiDPI: true).description == "2560x1440 HiDPI (5120x2880 px)")
        #expect(ModePlan(resolution: .defaultResolution, hiDPI: false).description == "2560x1440 1x (2560x1440 px)")
    }

    @Test func maxPixelsCoversTheLargestMode() {
        let plan = ModePlan(resolution: .defaultResolution, hiDPI: true)
        #expect(plan.maxPixels == Resolution(width: 7680, height: 4320))
    }
}

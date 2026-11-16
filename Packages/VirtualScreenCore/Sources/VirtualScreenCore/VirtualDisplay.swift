import CGVirtualDisplayPrivate
import CoreGraphics
import Foundation

public enum VirtualDisplayError: Error, CustomStringConvertible {
    case creationFailed
    case settingsRejected

    public var description: String {
        switch self {
        case .creationFailed: "CGVirtualDisplay could not be created"
        case .settingsRejected: "CGVirtualDisplay rejected the display modes"
        }
    }
}

/// Owns a `CGVirtualDisplay`. The display disappears as soon as this object is released.
public final class VirtualDisplay {
    // A fixed identity lets macOS remember the arrangement between launches.
    private static let name = "Virtual Screen"
    private static let vendorID: UInt32 = 0x5653
    private static let productID: UInt32 = 0x0001
    private static let serialNum: UInt32 = 0x0001
    private static let sizeInMillimeters = CGSize(width: 597, height: 336) // 27-inch 16:9
    private static let refreshRate = 60.0

    private let display: CGVirtualDisplay

    public var id: CGDirectDisplayID { display.displayID }

    /// `onTermination` runs on the main queue when the system removes the display.
    public init(plan: ModePlan, onTermination: @escaping () -> Void) throws(VirtualDisplayError) {
        let descriptor = CGVirtualDisplayDescriptor()
        descriptor.queue = .main
        descriptor.name = Self.name
        descriptor.vendorID = Self.vendorID
        descriptor.productID = Self.productID
        descriptor.serialNum = Self.serialNum
        descriptor.sizeInMillimeters = Self.sizeInMillimeters
        descriptor.maxPixelsWide = UInt32(plan.maxPixels.width)
        descriptor.maxPixelsHigh = UInt32(plan.maxPixels.height)
        descriptor.terminationHandler = { _, _ in onTermination() }

        guard let display = CGVirtualDisplay(descriptor: descriptor) else { throw .creationFailed }

        // Always enable HiDPI so both the 1x and 2x forms of every mode stay selectable.
        let settings = CGVirtualDisplaySettings()
        settings.hiDPI = 1
        settings.modes = plan.pixelModes.map {
            CGVirtualDisplayMode(width: UInt32($0.width), height: UInt32($0.height), refreshRate: Self.refreshRate)
        }
        guard display.apply(settings) else { throw .settingsRejected }

        self.display = display
    }
}

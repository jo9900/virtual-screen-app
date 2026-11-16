// Composes 2880x1800 Mac App Store screenshots from window-only captures in raw/.
// Usage: swift AppStore/screenshots/compose.swift   (run from the repository root)
import AppKit

struct Caption: Decodable {
    let image: String
    let headline: String
    let subhead: String
}

let root = URL(fileURLWithPath: "AppStore/screenshots")
let canvas = NSSize(width: 2880, height: 1800)
let menuBarHeight: CGFloat = 74
let menuScale: CGFloat = 1.6
let textLeft: CGFloat = 190
let textWidth: CGFloat = 1320

let topColor = NSColor(srgbRed: 0.36, green: 0.40, blue: 0.96, alpha: 1)
let bottomColor = NSColor(srgbRed: 0.10, green: 0.11, blue: 0.38, alpha: 1)

func load(_ name: String) -> NSBitmapImageRep {
    let url = root.appendingPathComponent("raw/\(name)")
    guard let data = try? Data(contentsOf: url), let rep = NSBitmapImageRep(data: data) else {
        fatalError("Missing \(url.path)")
    }
    return rep
}

/// The opaque part of a window capture, i.e. the menu without its shadow, in pixels from the top-left.
func opaqueBounds(of rep: NSBitmapImageRep) -> NSRect {
    var minX = rep.pixelsWide, minY = rep.pixelsHigh, maxX = 0, maxY = 0
    for y in 0..<rep.pixelsHigh {
        for x in 0..<rep.pixelsWide where (rep.colorAt(x: x, y: y)?.alphaComponent ?? 0) > 0.95 {
            minX = min(minX, x); maxX = max(maxX, x)
            minY = min(minY, y); maxY = max(maxY, y)
        }
    }
    return NSRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}

func drawBackground() {
    NSGradient(starting: topColor, ending: bottomColor)?.draw(in: NSRect(origin: .zero, size: canvas), angle: -60)
    let glowCenter = NSPoint(x: canvas.width * 0.7, y: canvas.height * 0.55)
    NSGradient(starting: NSColor(white: 1, alpha: 0.16), ending: NSColor(white: 1, alpha: 0))?
        .draw(fromCenter: glowCenter, radius: 0, toCenter: glowCenter, radius: 1100, options: [])
}

func drawMenuBar(iconCenterX: CGFloat) {
    NSColor(white: 1, alpha: 0.14).setFill()
    NSRect(x: 0, y: canvas.height - menuBarHeight, width: canvas.width, height: menuBarHeight).fill()

    let highlight = NSRect(x: iconCenterX - 46, y: canvas.height - menuBarHeight + 9, width: 92, height: menuBarHeight - 18)
    NSColor(white: 1, alpha: 0.28).setFill()
    NSBezierPath(roundedRect: highlight, xRadius: 18, yRadius: 18).fill()

    let config = NSImage.SymbolConfiguration(pointSize: 36, weight: .regular)
        .applying(.init(paletteColors: [.white]))
    if let symbol = NSImage(systemSymbolName: "display", accessibilityDescription: nil)?.withSymbolConfiguration(config) {
        let size = symbol.size
        symbol.draw(in: NSRect(x: iconCenterX - size.width / 2, y: highlight.midY - size.height / 2, width: size.width, height: size.height))
    }
}

/// Draws the menu capture hanging below the menu bar; returns the x of the menu's left edge.
func drawMenu(_ rep: NSBitmapImageRep) -> CGFloat {
    let body = opaqueBounds(of: rep)
    let width = CGFloat(rep.pixelsWide) * menuScale
    let height = CGFloat(rep.pixelsHigh) * menuScale
    let bodyLeft = canvas.width * 0.55
    let originX = bodyLeft - body.minX * menuScale
    let originY = canvas.height - menuBarHeight - 10 - (CGFloat(rep.pixelsHigh) - body.minY) * menuScale + height
    let image = NSImage(size: NSSize(width: rep.pixelsWide, height: rep.pixelsHigh))
    image.addRepresentation(rep)
    image.draw(in: NSRect(x: originX, y: originY - height, width: width, height: height))
    return bodyLeft
}

func drawText(_ caption: Caption, icon: NSImage) {
    let iconSize: CGFloat = 230
    let iconTop = canvas.height * 0.8
    icon.draw(in: NSRect(x: textLeft - 18, y: iconTop - iconSize, width: iconSize, height: iconSize))

    let paragraph = NSMutableParagraphStyle()
    paragraph.lineSpacing = 10
    let headline = NSAttributedString(string: caption.headline, attributes: [
        .font: NSFont.systemFont(ofSize: 112, weight: .bold),
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph,
    ])
    let subhead = NSAttributedString(string: caption.subhead, attributes: [
        .font: NSFont.systemFont(ofSize: 52, weight: .regular),
        .foregroundColor: NSColor(white: 1, alpha: 0.8),
        .paragraphStyle: paragraph,
    ])
    let options: NSString.DrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
    let headlineHeight = ceil(headline.boundingRect(with: NSSize(width: textWidth, height: 2000), options: options).height)
    let subheadHeight = ceil(subhead.boundingRect(with: NSSize(width: textWidth, height: 2000), options: options).height)

    let headlineTop = iconTop - iconSize - 50
    headline.draw(with: NSRect(x: textLeft, y: headlineTop - headlineHeight, width: textWidth, height: headlineHeight), options: options)
    let subheadTop = headlineTop - headlineHeight - 44
    subhead.draw(with: NSRect(x: textLeft, y: subheadTop - subheadHeight, width: textWidth, height: subheadHeight), options: options)
}

func render(_ caption: Caption, language: String, icon: NSImage) -> Data {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: Int(canvas.width), pixelsHigh: Int(canvas.height),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    ) else { fatalError("Could not allocate the canvas") }
    rep.size = canvas

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    drawBackground()
    let menuLeft = drawMenu(load("\(caption.image)-\(language).png"))
    drawMenuBar(iconCenterX: menuLeft + 46)
    drawText(caption, icon: icon)
    NSGraphicsContext.restoreGraphicsState()

    // App Store Connect rejects screenshots with an alpha channel.
    guard let cgImage = rep.cgImage,
          let context = CGContext(data: nil, width: cgImage.width, height: cgImage.height, bitsPerComponent: 8,
                                  bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
    else { fatalError("Could not flatten the canvas") }
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
    guard let flat = context.makeImage(),
          let png = NSBitmapImageRep(cgImage: flat).representation(using: .png, properties: [:])
    else { fatalError("Could not encode PNG") }
    return png
}

let captionsURL = root.appendingPathComponent("captions.json")
let captions = try JSONDecoder().decode([String: [Caption]].self, from: Data(contentsOf: captionsURL))
guard let icon = NSImage(contentsOf: root.appendingPathComponent("raw/AppIcon.icns")) else { fatalError("Missing icon") }

for (language, list) in captions.sorted(by: { $0.key < $1.key }) {
    let folder = root.appendingPathComponent(language)
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    for (index, caption) in list.enumerated() {
        let url = folder.appendingPathComponent("\(index + 1)-\(caption.image).png")
        try render(caption, language: language, icon: icon).write(to: url)
        print(url.path)
    }
}

import Cocoa

let size = 512
let iconSize = NSSize(width: size, height: size)

let image = NSImage(size: iconSize)
image.lockFocus()

// Background gradient
let context = NSGraphicsContext.current!.cgContext

let colorSpace = CGColorSpaceCreateDeviceRGB()
let locations: [CGFloat] = [0, 0.5, 1]
let colors = [
    CGColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 1.0),
    CGColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 1.0),
    CGColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0)
] as CFArray

let gradient = CGGradient(
    colorsSpace: colorSpace,
    colors: colors,
    locations: locations
)!

let center = CGPoint(x: size/2, y: size/2)
context.drawRadialGradient(
    gradient,
    startCenter: center,
    startRadius: 0,
    endCenter: center,
    endRadius: CGFloat(size) * 0.7,
    options: .drawsBeforeStartLocation
)

// Rounded rect clip
let rect = CGRect(x: 0, y: 0, width: size, height: size)
let path = CGPath(roundedRect: rect, cornerWidth: CGFloat(size) * 0.22, cornerHeight: CGFloat(size) * 0.22, transform: nil)
context.addPath(path)
context.clip()

// Trash icon
let trashSize: CGFloat = CGFloat(size) * 0.45
let trashOrigin = CGPoint(x: (CGFloat(size) - trashSize) / 2, y: CGFloat(size) * 0.25)
let trashRect = CGRect(origin: trashOrigin, size: CGSize(width: trashSize, height: trashSize * 1.2))

// Draw trash can body
context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.9))
// Lid
context.fill(CGRect(x: trashRect.origin.x - trashRect.width * 0.15, y: trashRect.maxY - 2, width: trashRect.width * 1.3, height: trashRect.height * 0.15))
// Body
let bodyPath = CGPath(roundedRect: CGRect(x: trashRect.origin.x, y: trashRect.origin.y, width: trashRect.width, height: trashRect.height * 0.75), cornerWidth: 4, cornerHeight: 4, transform: nil)
context.addPath(bodyPath)
context.fillPath()

// Slash through trash
context.setStrokeColor(CGColor(red: 1, green: 0.3, blue: 0.3, alpha: 0.95))
context.setLineWidth(trashSize * 0.12)
context.setLineCap(.round)
context.move(to: CGPoint(x: trashRect.minX - 4, y: trashRect.maxY + 2))
context.addLine(to: CGPoint(x: trashRect.maxX + 4, y: trashRect.minY - 6))
context.strokePath()

image.unlockFocus()

// Save as PNG
let pngData = image.tiffRepresentation!
let rep = NSBitmapImageRep(data: pngData)!
let finalData = rep.representation(using: .png, properties: [:])!
try finalData.write(to: URL(fileURLWithPath: "AppIcon.png"))
print("Icon generated: AppIcon.png")

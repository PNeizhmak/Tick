//
//  ColorScheme.swift
//  Tick
//
//  Created by Pavel Neizhmak on 01/04/2025.
//

import AppKit
import Foundation

enum ColorSchemeType: String, Codable {
    case classic
    case ocean
    case monochrome
    case adaptive
    case vivid
    case warm
    case cool
    case highContrast
    case custom
    case blueMenuContrast
}

struct RGBAColor: Codable {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
    let a: CGFloat
}

extension NSColor {
    func toRGBA() -> RGBAColor {
        let color = usingColorSpace(.sRGB) ?? self
        return RGBAColor(r: color.redComponent, g: color.greenComponent, b: color.blueComponent, a: color.alphaComponent)
    }
    static func from(_ rgba: RGBAColor) -> NSColor {
        return NSColor(srgbRed: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
    }
}

struct ColorScheme: Codable {
    var type: ColorSchemeType
    var high: RGBAColor
    var mid: RGBAColor
    var low: RGBAColor
    
    static func classic() -> ColorScheme {
        return ColorScheme(
            type: .classic,
            high: NSColor.systemGreen.toRGBA(),
            mid: NSColor.systemYellow.toRGBA(),
            low: NSColor.systemRed.toRGBA()
        )
    }
    
    static func ocean() -> ColorScheme {
        return ColorScheme(
            type: .ocean,
            high: NSColor.systemTeal.toRGBA(),
            mid: NSColor.systemBlue.toRGBA(),
            low: NSColor.systemIndigo.toRGBA()
        )
    }
    
    static func monochrome() -> ColorScheme {
        return ColorScheme(
            type: .monochrome,
            high: NSColor.gray.toRGBA(),
            mid: NSColor.lightGray.toRGBA(),
            low: NSColor.darkGray.toRGBA()
        )
    }

    static func vivid() -> ColorScheme {
        return ColorScheme(
            type: .vivid,
            high: NSColor.cyan.toRGBA(),
            mid: NSColor.systemPurple.toRGBA(),
            low: NSColor.systemOrange.toRGBA()
        )
    }

    static func warm() -> ColorScheme {
        return ColorScheme(
            type: .warm,
            high: NSColor.systemOrange.toRGBA(),
            mid: NSColor.systemYellow.toRGBA(),
            low: NSColor.brown.toRGBA()
        )
    }

    static func cool() -> ColorScheme {
        return ColorScheme(
            type: .cool,
            high: NSColor.systemTeal.toRGBA(),
            mid: NSColor.systemBlue.toRGBA(),
            low: NSColor.systemIndigo.toRGBA()
        )
    }

    static func highContrast() -> ColorScheme {
        return ColorScheme(
            type: .highContrast,
            high: NSColor.white.toRGBA(),
            mid: NSColor.systemYellow.toRGBA(),
            low: NSColor.black.toRGBA()
        )
    }

    // Optimized for blue-tinted menu bars: warm/bright colors with strong contrast
    static func blueMenuContrast() -> ColorScheme {
        return ColorScheme(
            type: .blueMenuContrast,
            high: NSColor.yellow.toRGBA(),
            mid: NSColor.orange.toRGBA(),
            low: NSColor.magenta.toRGBA()
        )
    }
}

final class ColorSchemeProvider {
    static func adaptiveScheme(for appearance: NSAppearance? = NSApp.effectiveAppearance) -> ColorScheme {
        let isDark = appearance?.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        // Choose colors with strong contrast for the current appearance
        if isDark {
            return ColorScheme(
                type: .adaptive,
                high: NSColor.cyan.toRGBA(),
                mid: NSColor.systemOrange.toRGBA(),
                low: NSColor.systemPink.toRGBA()
            )
        } else {
            return ColorScheme(
                type: .adaptive,
                high: NSColor.systemGreen.toRGBA(),
                mid: NSColor.systemOrange.toRGBA(),
                low: NSColor.systemRed.toRGBA()
            )
        }
    }
}



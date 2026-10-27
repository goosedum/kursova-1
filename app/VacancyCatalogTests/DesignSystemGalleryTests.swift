//
//  DesignSystemGalleryTests.swift
//  Рендер вітрини дизайн-системи в PNG (світла і темна теми) — для порівняння з Figma і для звіту.
//

import AppKit
import SwiftUI
import Testing
@testable import VacancyCatalog

/// Перевіряє, що вітрина дизайн-системи будується, і зберігає її знімки в тимчасову папку
/// (шлях друкується в журнал тестів: `design-system-light.png`, `design-system-dark.png`).
@MainActor
struct DesignSystemGalleryTests {

    @Test("Вітрина рендериться у світлій і темній темах", arguments: [ColorScheme.light, ColorScheme.dark])
    func galleryRenders(colorScheme: ColorScheme) throws {
        let renderer = ImageRenderer(content: DesignSystemGallery().environment(\.colorScheme, colorScheme))
        renderer.scale = 2
        let image = try #require(renderer.nsImage)
        #expect(image.size.width > 0)

        // Знімок у PNG: NSImage → TIFF → растр → PNG
        let tiff = try #require(image.tiffRepresentation)
        let bitmap = try #require(NSBitmapImageRep(data: tiff))
        let png = try #require(bitmap.representation(using: .png, properties: [:]))
        var name = "design-system-light.png"
        if colorScheme == .dark {
            name = "design-system-dark.png"
        }
        let url = FileManager.default.temporaryDirectory.appending(path: name)
        try png.write(to: url)
        print("Знімок вітрини: \(url.path(percentEncoded: false))")
    }
}

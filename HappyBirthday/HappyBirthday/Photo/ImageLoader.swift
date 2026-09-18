//
//  ImageLoader.swift
//  HappyBirthday
//
//  Created by Choi, David on 9/17/26.
//

import UIKit
import ImageIO

// Decodes + downsamples an image file OFF the main thread using ImageIO.
// Avoids the full-resolution UIImage(contentsOfFile:) decode that otherwise runs
// on the main thread inside a view's `body` on every render.
enum ImageLoader {
    /// Load `url` as a UIImage downsampled so its largest edge is ~`maxPixelSize` PIXELS.
    /// Returns nil if the file is missing or undecodable.
    static func downsampledImage(at url: URL, maxPixelSize: CGFloat) async -> UIImage? {
        await Task.detached(priority: .userInitiated) {
            let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else { return nil }

            let thumbnailOptions: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,   // respect EXIF orientation
                kCGImageSourceThumbnailMaxPixelSize: max(1, maxPixelSize)
            ]
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        }.value
    }
}

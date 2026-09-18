//
//  LocalPhotoStore.swift
//  HappyBirthday
//
//  Created by Choi, David on 9/13/26.
//


import Foundation
import UIKit

protocol PhotoStore {
    func save(_ image: UIImage, replacing oldFilename: String?) async -> String?
}

struct LocalPhotoStore: PhotoStore {
    // JPEG encode + disk write run off the main thread; only the tiny filename returns.
    func save(_ image: UIImage, replacing oldFilename: String?) async -> String? {
        await Task.detached(priority: .userInitiated) {
            guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }

            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = "baby_photo_\(UUID().uuidString).jpg"
            do {
                try data.write(to: documentsURL.appendingPathComponent(filename), options: .atomic)
            } catch {
                return nil
            }

            // Delete the previous file only AFTER the new one is safely written,
            // so a failed write never loses the existing photo.
            if let oldFilename, oldFilename != filename {
                try? FileManager.default.removeItem(at: documentsURL.appendingPathComponent(oldFilename))
            }
            return filename
        }.value
    }
}

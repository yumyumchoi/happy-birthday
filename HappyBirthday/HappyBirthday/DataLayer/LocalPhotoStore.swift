//
//  LocalPhotoStore.swift
//  HappyBirthday
//
//  Created by Choi, David on 9/13/26.
//


import Foundation
import UIKit

protocol PhotoStore {
    func save(_ image: UIImage, replacing oldFilename: String?) -> String?
}

struct LocalPhotoStore: PhotoStore {
    private let fileManager = FileManager.default

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func save(_ image: UIImage, replacing oldFilename: String?) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }

        let filename = "baby_photo_\(UUID().uuidString).jpg"
        do {
            try data.write(to: documentsURL.appendingPathComponent(filename), options: .atomic)
        } catch {
            return nil
        }

        // Delete the previous file only AFTER the new one is safely written,
        // so a failed write never loses the existing photo.
        if let oldFilename, oldFilename != filename {
            try? fileManager.removeItem(at: documentsURL.appendingPathComponent(oldFilename))
        }
        return filename
    }
}

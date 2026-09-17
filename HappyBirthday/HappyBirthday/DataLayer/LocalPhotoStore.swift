//
//  LocalPhotoStore.swift
//  HappyBirthday
//
//  Created by Choi, David on 9/13/26.
//

// Photos needs to be stored locally so that it will be present in the next app launch
// Store the files locally in file system. Store it in document folder.

import Foundation
import UIKit

protocol PhotoStore {
    func save(_ image: UIImage) -> String?
    func loadImage(named filename: String) -> UIImage?
}

struct LocalPhotoStore: PhotoStore {
    private let fileManager = FileManager.default
    private let filename = "baby_photo.jpg"

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func save(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let url = documentsURL.appendingPathComponent(filename)
        do {
            try data.write(to: url, options: .atomic)
            return filename
        } catch {
            return nil
        }
    }

    func loadImage(named filename: String) -> UIImage? {
        let url = documentsURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}

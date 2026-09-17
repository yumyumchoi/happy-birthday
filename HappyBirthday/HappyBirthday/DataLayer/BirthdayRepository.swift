//
//  BirthdayRepository.swift
//  happy-birthday
//
//  Created by Choi, David on 9/13/26.
//

import Foundation
import UIKit

enum MetadataStoreKey: String {
    case name
    case birthday
    case photoImageFileName
}

protocol DataRepository: AnyObject {
    var name: String? { get set }
    var birthday: Date? { get set }
    var photoImageURL: URL? { get }
    func savePhotoImage(_ image: UIImage)
}

// central data store to serve as source of truth for all views.  viewmodels rely on this to fetch from disk, and supply with hydrated data for view render
@MainActor
@Observable
class BirthdayRepository: DataRepository {
    var name: String? {
        didSet {
            guard let name else { return }
            localMetadataStore.setString(name, for: MetadataStoreKey.name.rawValue)
        }
    }
    var birthday: Date? {
        didSet {
            guard let birthday else { return }
            localMetadataStore.setDate(birthday, for: MetadataStoreKey.birthday.rawValue)
        }
    }
    private(set) var photoImageURL: URL?
    private var photoFileName: String?

    // while we can have repo actually do the job of fetching/saving metadata, extra wrapper for appstorage is added as separate data provider, for better separation of concern, and testability
    private let localMetadataStore: MetadataStore
    private let localPhotoStore: PhotoStore
    
    init(localMetadataStore: MetadataStore, localPhotoStore:PhotoStore) {
        self.localMetadataStore = localMetadataStore
        self.localPhotoStore = localPhotoStore
        name = localMetadataStore.string(MetadataStoreKey.name.rawValue)
        birthday = localMetadataStore.date(MetadataStoreKey.birthday.rawValue)
        photoFileName = localMetadataStore.string(MetadataStoreKey.photoImageFileName.rawValue)
        photoImageURL = photoFileNameToURL(photoFileName)
    }
    
    func savePhotoImage(_ image: UIImage) {
        guard let newFileName = localPhotoStore.save(image, replacing: photoFileName) else { return }
        photoFileName = newFileName
        localMetadataStore.setString(newFileName, for: MetadataStoreKey.photoImageFileName.rawValue)
        photoImageURL = photoFileNameToURL(newFileName)
    }
    
    private func photoFileNameToURL(_ fileName: String?) -> URL? {
        guard let fileName else { return nil }
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }
}

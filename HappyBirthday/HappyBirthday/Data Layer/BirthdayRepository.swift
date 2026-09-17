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
    case photoImageURL
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
    
    // while we can have repo actually do the job of fetching/saving metadata, extra wrapper for appstorage is added as separate data provider, for better separation of concern, and testability
    private let localMetadataStore: MetadataStore
    
    init(localMetadataStore: MetadataStore) {
        self.localMetadataStore = localMetadataStore
        name = localMetadataStore.string(MetadataStoreKey.name.rawValue)
        birthday = localMetadataStore.date(MetadataStoreKey.birthday.rawValue)
    }
    
    // TODO :: Image retrieve from camera + album
    
    func savePhotoImage(_ image: UIImage) {
        
    }
    
    var photoImageURL: URL? {
        get {
            return nil
        }
    }
}

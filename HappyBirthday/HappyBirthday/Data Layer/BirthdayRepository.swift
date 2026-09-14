//
//  BirthdayRepository.swift
//  happy-birthday
//
//  Created by Choi, David on 9/13/26.
//

import Foundation
import UIKit


protocol DataRepository {
    func getBabyData() -> BabyData?
    func saveBabyName(_ name:String)
    func saveBabyBirthdayDate(_ date:Date)
    func saveBabyPhotoImage(_ image: UIImage)
}

// central data store to serve as source of truth for all views.  viewmodels rely on this to fetch from disk, and supply with hydrated data for view render
@MainActor
class BirthdayRepository: DataRepository {
    // while we can have repo actually do the job of fetching/saving metadata, extra wrapper for appstorage is added as separate data provider, for better separation of concern, and testability
    private let localMetadataStore: MetadataStore
    
    init(localMetadataStore: MetadataStore) {
        self.localMetadataStore = localMetadataStore
    }
    
    func getBabyData() -> BabyData? {
        return nil
    }
    
    func saveBabyName(_ name:String) {
        
    }
    
    func saveBabyBirthdayDate(_ date:Date) {
        
    }
    
    // Used by photo picker (which would handle camera/album image fetch), and route it here to persist to local disk
    func saveBabyPhotoImage(_ image: UIImage) {
        // serialize the image
        
        // save the local image path to appstorage
    }
    
    // TODO :: Image retrieve from camera + album
}

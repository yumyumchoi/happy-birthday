//
//  LocalMetadataStore.swift
//  happy-birthday
//
//  Created by Choi, David on 9/13/26.
//

import Foundation
import UIKit

// Store and access metadata: name/birthday
// No state stored here, just pure static methods to access data direclty and funneled back to caller.

protocol MetadataStore {
    func string(_ key: String) -> String?
    func setString(_ value:String, for key: String)
    
    func date(_ key: String) -> Date?
    func setDate(_ value:Date, for key: String)
}

class LocalMetadataStore: MetadataStore {
    private let defaults = UserDefaults.standard
    
    func string(_ key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    func setString(_ value: String, for key: String) {
        defaults.set(value, forKey: key)
    }
    
    func date(_ key: String) -> Date? {
        return defaults.object(forKey: key) as? Date
    }
    
    func setDate(_ value: Date, for key: String) {
        defaults.set(value, forKey: key)
    }
}

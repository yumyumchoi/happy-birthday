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
    func string(forKey: String) -> String?
    func setString(_ value:String, for key: String)
    
    func date(forKey: String) -> Date?
    func setDate(_ value:Date, for key: String)
}

class LocalMetadataStore: MetadataStore {
    func string(forKey: String) -> String? {
        return nil
    }
    
    func setString(_ value: String, for key: String) {
        
    }
    
    func date(forKey: String) -> Date? {
        return nil
    }
    
    func setDate(_ value: Date, for key: String) {
        
    }
}

//
//  BabyModel.swift
//  HappyBirthday
//
//  Created by Choi, David on 9/13/26.
//

import Foundation

// all 3 are optional because user can save any one of them sepately, and we need to return valid value after launch
struct BabyData {
    var name: String?
    var birthday: Date?
    var photoURL: URL?
}

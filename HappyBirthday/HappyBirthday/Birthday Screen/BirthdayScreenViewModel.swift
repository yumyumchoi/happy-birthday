//
//  BirthdayScreenViewModel.swift
//  HappyBirthday
//
//  Created by Choi, David on 9/13/26.
//

import Foundation

@MainActor
@Observable
class BirthdayScreenViewModel {
    public var name: String? {
        get {
            return repo.name
        }
    }
    public var birthday:  Date? {
        get {
            return repo.birthday
        }
    }
    public var photoImageURL: URL? {
        get {
            return repo.photoImageURL
        }
    }
    
    private let repo: DataRepository
    
    init(repo: DataRepository) {
        self.repo = repo
    }
}

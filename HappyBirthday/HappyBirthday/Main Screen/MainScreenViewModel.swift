//
//  MainScreenViewModel.swift
//  HappyBirthday
//
//  Created by Choi, David on 9/13/26.
//

import SwiftUI

// Orchestrates data from data layer to view, and updates user input from view layer to data
@MainActor
@Observable
class MainScreenViewModel {
    private var repo: DataRepository
    
    public var name: String? {
        get { return repo.name }
        set { repo.name = newValue }
    }
    
    public var hasBirthday: Bool {
        get { return birthday != nil }
    }
    
    public var birthday: Date?  {
        get { return repo.birthday }
        set { repo.birthday = newValue }
    }
    
    public var photoImageURL: URL?  {
        get { return repo.photoImageURL }
    }
    
    init(repo: BirthdayRepository) {
        self.repo = repo
    }
}

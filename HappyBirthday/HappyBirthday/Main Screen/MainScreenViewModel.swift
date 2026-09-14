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
    private let repo: BirthdayRepository
    
    init(repo: BirthdayRepository) {
        self.repo = repo
    }
}

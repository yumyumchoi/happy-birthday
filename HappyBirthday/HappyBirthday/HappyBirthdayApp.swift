//
//  HappyBirthdayApp.swift
//  HappyBirthday
//
//  Created by Choi, David on 9/13/26.
//

import SwiftUI

@main
struct HappyBirthdayApp: App {
    @State private var repo = BirthdayRepository(localMetadataStore: LocalMetadataStore())
    
    var body: some Scene {
        WindowGroup {
            RootNavigationView().environment(repo)
        }
    }
}
